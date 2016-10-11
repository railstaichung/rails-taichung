# 第十二章 关注用户

在这章，我们将通过添加社交层来允许用户关注（和取消关注）来完成示例应用程序，结果会在每个用户的主页显示关注用户的微博的状态feed。我们将通过学习怎样模型化用户之间的关系在12.1节开始，然后我们将在12.2节建立相应的web接口（包含引入Ajax）。我们将通过开发完整的函数状态feed在12.3节结束开发。

最后一章包含一些本书里最具挑战性德内容，包含一些Ruby/SQL创建状态feed的花招。通过这些立即，你将看见怎样Rails能处理甚至错综复杂的数据模型，它应该当你继续看法你自己的应用程序用他们自己的详细的需求服务好你。为了帮助从教程到独立开发的过渡，12.4节提供一些迈向更高层次的资源。

因为在本章的材料里是尤其有挑战的，在写代码前我们将暂停一会，看看接口。如在之前的章节里，在早期我们将使用页面模型来代表。完整的页面流运行如下：用户（Jone
Calvin）在他的个人信息也开始（图12.1），然后导航到Users页面（图12.2），选择用户来关注。Calvin导航到另一个用户的个人信息也，Thamas
Hobbes（图12.3），点击“Follow”按钮关注用户。这会让“Follow”变成“Unfollow”，然后增加Hobbes的“关注着”数量，在他的状态feed里查找Hobbes的微博（图12.5）。剩下的章节就是让这些真实的工作。

![图12.1：当前用户个人信息页](https://softcover.s3.amazonaws.com/636/ruby_on_rails_tutorial_3rd_edition/images/figures/page_flow_profile_mockup_3rd_edition.png)
![图12.2：查找准备关注的用户](https://softcover.s3.amazonaws.com/636/ruby_on_rails_tutorial_3rd_edition/images/figures/page_flow_user_index_mockup_bootstrap.png)
![图12.3：带关注按钮的用户个人信息页面](https://softcover.s3.amazonaws.com/636/ruby_on_rails_tutorial_3rd_edition/images/figures/page_flow_other_profile_follow_button_mockup_3rd_edition.png)
![图12.4：带取消关注按钮和增加的关注者数量的个人信息页面](https://softcover.s3.amazonaws.com/636/ruby_on_rails_tutorial_3rd_edition/images/figures/page_flow_other_profile_unfollow_button_mockup_3rd_edition.png)
![图12.5：带状态feed的主页和增加关注的数量的主页](https://softcover.s3.amazonaws.com/636/ruby_on_rails_tutorial_3rd_edition/images/figures/page_flow_home_page_feed_mockup_3rd_edition.png)

## 12.1 关系模型
我们第一步在实现关注用户是构建数据模型，它不是和它看上去那样直接。直白地，它好像has_many关系会做的：用户has_many关注用户和has_many关注者。如我们将看到的，这个方法有个问题，我们将学习怎样使用has_many :through来解决它。

和往常一样，Git用户将创建新主题分支：
```ruby
$ git checkout master
$ git checkout -b following-users
```

### 12.1.1 带数据模型的问题（和解决方法）
作为朝向构建数据模型为关注用户的第一步，让我们检验一个典型的情形。例如，考虑用户关注另一个用户：我们可以说，例如，Calvin正关注Hobbes，
Hobbes被Calvin关注，所以Calvin是关注者，Hobbes是被关注。使用Rails的默认辅助惯例，关注所给用户的集合是用户的关注者，hobbes.followers是那些用户的数组。不幸地是，反过来就不一样了：默认地，所有关注用户的集合将被称为被关注者，这不符合语法，有点难听。我们将使用Twitter的惯例，叫正关注他们（如“正关注50个用户，75个关注者”），有相应的calvin.following数组。

这个讨论暗示如图12.6那样模型化被关注的用户，用following表和has_many关联。因为user.following应该是用户的集合，following表每行都需要一个用户，如被followed_id识别的，和建立这个关联的follower_id一起。另外，因为每行是一个用户，我们需要包含用户的其他属性，包括姓名、email、密码等。

![图12.6：用户关注者的原始实现](https://softcover.s3.amazonaws.com/636/ruby_on_rails_tutorial_3rd_edition/images/figures/naive_user_has_many_following.png)

在图12.6里的数据模型的问题是它冗余的恐怖：每行不仅包含每个被关注的用户的id，还有其他别的信息--所有这些信息已经在users表了。更坏得是，为了模型化用户的关注者，我们需要单独地，相似的冗余的follower表。最后，这个数据模型成了维护的梦魇：每次用户改变了他们的名字，我们不仅要根性用户的记录在users表里的，而且要更新following和follower表的每行用户。

这里的问题是我们正迷失底层抽象。找到正确的模型的方法之一是考虑我们怎么实现following动作在Web应用程序。回忆7.1.2节，REST架构需要资源被创建和被删除。这引起我们问两个问题：当用户关注另一个用户是，什么被创建？当用户取消关注另一个用户时，什么被删除？在反射上，我们看见在这些例子应用程序应该也创建或删除两个用户之间的关系。用户有很多关系，有许多正在关注的用户following（或者关注他的follower）通过这些关系。

有一个额外的细节我们需要表明考虑我们的应用程序的数据模型：不像对称的Facebook类型的关系，它是相互的（起码在数据模型水平），Twitter型关注关系是潜在不对称的-Calvin可以关注Hobbes，Hobbes可以不关注Calvin。为了区分这两种情况，我们将采取主动和被动关系的术语：假如Calvin正关注Hobbes，但是Hobbes没有关注Calvin，Calvin有一个主动的关系和Hobbes，Hobbes有一个被动的关系和Calvin。

我们将聚焦使用主动关系来生成一列被关注的用户，考虑被动的例子在12.1.5节。图12.6暗示怎样实现它：因为每个被关注的用户是通过follow_id唯一的识别，我们能把following转换到active_relationships表，忽略用户细节，使用followed_id来从users表被关注的用户。数据模型显示在图12.7
![图12.7：
通过主动关系的关注的用户模型](https://softcover.s3.amazonaws.com/636/ruby_on_rails_tutorial_3rd_edition/images/figures/user_has_many_following_3rd_edition.png)
因为我们使用同样的数据表为主动和被动关系来结束，我们将使用一般的术语relationship作为表名，相应的模型为Relationship。结果是显示在图12.8的Relationship数据模型。我们将在12.1.4节里开始怎样使用Relationship模型来模拟Active Relationship和被动Relationship模型。
![图12.8：Relationship数据模型](https://softcover.s3.amazonaws.com/636/ruby_on_rails_tutorial_3rd_edition/images/figures/relationship_model.png)
为了开始实现，我们首先生成图12.8相应的数据迁移：
```ruby
$ rails generate model Relationship follower_id:integer followed_id:integer
```
因为我们将发现关系通过follower_id和followed_id，我们为了效率应该在每列上添加一个索引，如在清单12.1所示。
```ruby
代码清单 12.1: Adding indices for the relationships table.
# db/migrate/[timestamp]_create_relationships.rb
 class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps null: false
    end
    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
    add_index :relationships, [:follower_id, :followed_id], unique: true
  end
end
```
清单12.1也包含多键索引来强制唯一在（follower_id和followed_id)对上，以便永不不能关注别的用户多余一次。（比较email唯一性索引从清单6.28和在清单11.1的多键索引。）如我们在12.1.4节开始看见的，我们用户接口不会允许这发生，但是添加唯一索引，假如用户尝试创建重复关系是抛出错误（例如，通过使用命令行工具，如curl）。

为了创建relationships表，我们如往常一样进行数据库迁移：
```ruby
$ bundle exec rake db:migrate
```
### 12.1.2 User/relationship关联
在实现用户关注和关注者之前，我们首先需要建立关联在用户和关系之间。用户has_many关系，和--因为关系需要两个用户--关系belongs_to关注者和被关注的用户。

和在11.1.3节里的微博一样，我们将创建新的关系使用用户关联，用类似下面的代码
```ruby
user.active_relationships.build(followed_id: ...)
```
在这点，你可能期盼如在11.1.3节里的应用程序代码，它是相似的，但是有两个关键的不同点。

首先，在用户/微博关联的情形，我们可以写
```ruby
class User < ActiveRecord::Base
  has_many :microposts
  .
  .
  .
end
```
这工作因为通过惯例，Rails查找Micropost模型相应的:microposts符号。在目前的例子，不过，我们想写
```ruby
has_many :actve_relationships
```
即使基础模型被命名为Relationship。我们因此不得不告诉Rails寻找的模型的类名。

其次，在我们写以下代码之前
```ruby
class Micropost < ActiveRecord::Base
  belongs_to :user
  .
  .
  .
end
```
在Micropost模型里。这工作是因为microposts表有user_id属性来是吧用户（11.1.1节）。id使用在这个形式为了连接两个数据库表被作为熟知的外键，当外键为User模型对象是user_id, Rails自动推理啊关联：默认地，Rails期盼表单的外键<class>_id，这里<class>是小写的类名。在当前的例子，尽管我们仍处理用户，用户关注其他用户现在是通过外键follower_id识别，所以我们不得不告诉Rails。

上面讨论的结果就是用户/关系关联显示在清单12.2和清单12.3.
```ruby
代码清单 12.2: Implementing the active relationships has_many association.
# app/models/user.rb
 class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy
  .
  .
  .
end
```
(因为删除用户也应该删除用户的关系，我们添加dependent: :dstroy到关联）
```ruby
代码清单 12.3: Adding the follower belongs_to association to the Relationship
model.
# app/models/relationship.rb
 class Relationship < ActiveRecord::Base
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
end

```
followed关联不是实际需要知道12.1.5节，但是相似的follower/followed结构是更清晰的，假如我们同时实现他们。

关系在清单12.2和清单12.3带出了和我们在表11.1所见的相似的方法，如表12.1所示。
表12.1：用户/主动关系关联方法

### 12.1.3 Relationship有效性验证
在我们继续前，我们将为补全添加几个Relationship模型有效性验证。测试（清单12.4）和应用程序代码（清单12.5）是简单的。和生成的用户fixture（清单6.29），生成的关系fixtur也通过相应的数据迁移违反了唯一限制强制（清单12.1）。解决方法是（移除fixture内容在清单6.30里的）也一样（清单12.6）。
```ruby
代码清单 12.4: Testing the Relationship model validations.
# test/models/relationship_test.rb
 require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase

  def setup
    @relationship = Relationship.new(follower_id: 1, followed_id: 2)
  end

  test "should be valid" do
    assert @relationship.valid?
  end

  test "should require a follower_id" do
    @relationship.follower_id = nil
    assert_not @relationship.valid?
  end

  test "should require a followed_id" do
    @relationship.followed_id = nil
    assert_not @relationship.valid?
  end
end
```
```ruby
代码清单 12.5: Adding the Relationship model validations.
# app/models/relationship.rb
 class Relationship < ActiveRecord::Base
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
  validates :follower_id, presence: true
  validates :followed_id, presence: true
end
```
```ruby
代码清单 12.6: Removing the contents of the relationship fixture.
# test/fixtures/relationships.yml
 # empty
```
在这点，测试应该是绿色的：
```ruby
代码清单 12.7: 绿色
$ bundle exec rails test
```

### 12.1.4 被关注的用户

我们现在来到了Relationship关联的核心：following和followers。这里我们将使用has_many
:through第一次：用户有许多正关注的（following）通过（through）关系（relationships），如在图12.7阐明的。默认地，在has_many :through关联里，Rails查找相应的关联单数版本的外键。换句话说，像代码
```ruby
has_many :followers, through: :active_relationships
```
Rails将会看见“followeds”和使用单数“followed”，使用followed_id在relationships表里组成的集合。但是，如在12.1.1节表明，user.followeds是很尴尬的，所以我们将用user.following来代替。自然地，Rails允许我们覆盖默认，在这个例子，使用source参数（图在清单12.8里所示），显式地告诉Railsfollowing数组的资源是followed
id的集合。

```ruby
代码清单 12.8: Adding the User model following association.
# app/models/user.rb
 class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy
  has_many :following, through: :active_relationships, source: :followed
  .
  .
  .
end
```
定义在清单12.8里的关联导致了强有力的Active
Record组合和像数组一样的行为。例如，我们能坚持是否被关注的用户集合包含另一个用户用include?方法（4.3.1节），或者查找对象通过关联：
```ruby
user.following.include?(other_user)
user.following.find(other_user)
```
尽管在许多环境，我们能有效地对待following作为数组，Rails是聪明的关于怎样在后台处理它。例如，像代码：
```ruby
following.include?(other_user)
```
看起来像它可能不得不从数据库拉取所有的被关注的用户为了应用include?方法，但是事实上，为了效率Rails直接在数据库准备了比较。（比较在11.2.1的代码，在那里我们见过
```ruby
user.microposts.count
```
直接在数据库里执行了计数）
为了操作following关系，我们将引入follow和unfollow工具方法，以便我们能写，例如，user.follow(other_user).我们也将添加相关的following?逻辑方法来测试是否用户正关注另一个。

这是确切的那种我想要先写测试的情形。原因是我们离为正关注的用户写工作的web接口距离还很远，但是执行没有一点客户为我们正在开发的代码是艰难地。在这种情况，为User模型写一个简短的测试是更容易，在测试里我们使用following?来确保用户没有关注另一个用户，使用follow来关注另一个欧诺个户，使用following?来确认操作成功，最后unfollow和确认它会工作。结果显示在清单12.9里。
```ruby
代码清单 12.9: Tests for some “following” utility methods. 红色
# test/models/user_test.rb
 require 'test_helper'

class UserTest < ActiveSupport::TestCase
  .
  .
  .
  test "should follow and unfollow a user" do
    michael = users(:michael)
    archer  = users(:archer)
    assert_not michael.following?(archer)
    michael.follow(archer)
    assert michael.following?(archer)
    michael.unfollow(archer)
    assert_not michael.following?(archer)
  end
end
```
通过参考在表12.1里的方法，我们能写follow，unfollow，和following?方法使用和following相关的，如清单12.10所示。（注意我们已经忽略了用户self变量无论何时可能）
```ruby
代码清单 12.10: Utility methods for following. 绿色
# app/models/user.rb
 class User < ActiveRecord::Base
  .
  .
  .
  def feed
    .
    .
    .
  end

  # Follows a user.
  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  # Unfollows a user.
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # Returns true if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user)
  end

  private
  .
  .
  .
end
```
有了在清单12.10里的测试，测试应该是绿色的：
```ruby
代码清单 12.11: 绿色
$ bundle exec rails test
```
### 12.1.5 关注者Followers
最后的关系的迷惑是添加user.followers方法到user.following。你可能也许注意从图12.7里，所有需要的信息从关注者的数组抽取出来的是在relationships表里呈现的（我们通过代码在清单12.2里的把它当做active_relationships表）。确实，技术是和被关注的用户一样，有了follower_id和followed_id倒置的角色，和用passive_relationships替换了active_relationships。数据模型然后显示在图12.9。
![图12.9：用户通过被动关系表的关注着的模型](https://softcover.s3.amazonaws.com/636/ruby_on_rails_tutorial_3rd_edition/images/figures/user_has_many_followers_3rd_edition.png)

图12.9的数据模型的实现和清单12.8一模一样，如在清单12.12里所见。
```ruby
代码清单 12.12: Implementing user.followers using passive relationships.
# app/models/user.rb
 class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy
  has_many :active_relationships,  class_name:  "Relationship",
                                   foreign_key: "follower_id",
                                   dependent:   :destroy
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  has_many :following, through: :active_relationships,  source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  .
  .
  .
end
```
值得一提的是我们实际上可以忽略:source键，在清单12.12里，只使用
`has_many :followers, through: :passive_relationships`
这是因为在:followers属性的情形，Rails将单数话“followers”，自动查找外键folloer_id在这种情形，清单12.8保持:source键为了强调和has_many
：following关联的相似结构。
我们能方便地测试以上数据模型，使用followers.include?方法，如在清单12.13所示。（清单12.13可能使用followed_by?方法来完成following?方法，但是它证明我们在我们的应用程序里不需要它）
```ruby
代码清单 12.13: A test for followers. 绿色
# test/models/user_test.rb
 require 'test_helper'

class UserTest < ActiveSupport::TestCase
  .
  .
  .
  test "should follow and unfollow a user" do
    michael  = users(:michael)
    archer   = users(:archer)
    assert_not michael.following?(archer)
    michael.follow(archer)
    assert michael.following?(archer)
    assert archer.followers.include?(michael)
    michael.unfollow(archer)
    assert_not michael.following?(archer)
  end
end
```
清单12.13仅仅从清单12.9里添加了一行，但是如此多得东西不得不正确，为了让它通过，在清单12.12里的代码是很敏感的测试。
在这点，测试集应该是绿色的：
```ruby
$ bundle exec rails test
```

## 12.2 为正关注的用户的网络接口
12.1节对我们的数据模型化技能有很高的要求，假如你需要花点时间吸收，这很正常。实际上，理解这个关联最好的方法是在网络界面使用它。

在介绍这章是，我们看见为用户关注的页面流预览。在这节，我们将实现基本的界面，以及正关注/不再关注功能在那些页面模型里显示的。我们也创建单独的页面来显示用户正关注的和关注者数组。在12.3节里，我们将完成我们的示例应用程序通过添加用户的状态流。

### 12.2.1 正关注的用户的样本数据
如在之前的章节里，我们将发现它方便的，使用繁殖数据Rake任务来使用示例关系填充数据库。这也将允许我们首先设计界面和网页的感觉，把后端功能实现推迟到本节最后。

繁殖正关注的关系的数据的代码显示在清单212.14里。这里我们有点武断地安排第一个用户从51个用户里关注3个，然后从41个用户里关注他。结果的关系将是对于开发应用程序界面是熟悉的。
```ruby
代码清单 12.14: Adding following/follower relationships to the sample data.
# db/seeds.rb
 # Users
User.create!(name:  "Example User",
             email: "example@railstutorial.org",
             password:              "foobar",
             password_confirmation: "foobar",
             admin:     true,
             activated: true,
             activated_at: Time.zone.now)

99.times do |n|
  name  = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(name: name,
              email: email,
              password:              password,
              password_confirmation: password,
              activated: true,
              activated_at: Time.zone.now)
end

# Microposts
users = User.order(:created_at).take(6)
50.times do
  content = Faker::Lorem.sentence(5)
  users.each { |user| user.microposts.create!(content: content) }
end

# Following relationships
users = User.all
user  = users.first
following = users[2..50]
followers = users[3..40]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }
```
为了执行清单12.14里的代码，我们如往常一样重新繁殖数据库：
```ruby
$ bundle exec rake db:migrate:reset
$ bundle exec rake db:seed
```
### 12.2.2 统计和关注表单
现在我们的示例用户有被关注的用户和关注者，我们需要更新个人信息页面和主页来反射这些。我们将通过创建一个视图片段来显示正关注的和关注着统计在个人信息页面和主页来开始。我们接下来添加一个关注/取消关注表单，然后魏显示“正关注（被关注的用户”和“关注者”创建.

如在12.11节里提到的，我们将采用Twitter的惯例使用"following"作为被关注用户的标签，如“50正关注的”。这个用法反应在后续的页面模型在图12.1开始和显示在图12.10里的特写。
![图12.10：统计视图片段的页面模型](https://softcover.s3.amazonaws.com/636/ruby_on_rails_tutorial_3rd_edition/images/figures/stats_partial_mockup.png)

在图12.10里的统计包含了当前用户正关注的用户数和关注者的用户数，每个应该是到各自贡献的显示页面。在第五章，我们用假链接‘#’来模拟这样的链接，但是我们那是对路由有了更多经验之前。这次，经我们推迟时间页面到12.2.3级，我们现在创建路由，如在清单12.15里所见。这段代码使用:member方法在resources块里，我们之前没有见过，但是看看是否你能猜到它是什么。
```ruby
代码清单 12.15: Adding following and followers actions to the Users controller.
# config/routes.rb
 Rails.application.routes.draw do
  root                'static_pages#home'
  get    'help'    => 'static_pages#help'
  get    'about'   => 'static_pages#about'
  get    'contact' => 'static_pages#contact'
  get    'signup'  => 'users#new'
  get    'login'   => 'sessions#new'
  post   'login'   => 'sessions#create'
  delete 'logout'  => 'sessions#destroy'
  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :microposts,          only: [:create, :destroy]
end
```
你可能怀疑URL为following和followers的将看起来像/users/1/following和/users/1/followers，这恰好是清单12.15里安排的。因为两个页面正显示数据，正确的HTTP动词是GET请求，所以我们使用get方法来为URL到合适想要来准备。同时member方法准备路由相应到URL包含用户id。别的可能性，collection,不用id工作，以便
```ruby
resources :users do
  collection do
    get :tigers
  end
end
```
将响应URL /users/tigers（设想在我们的应用程序里显示老虎）。
清单12.15生成的路由显示在表12.2.注意命名路由为被关注的用户和关注着的页面，我们将简短地使用。
表12.2： 在清单12.15里自定义路由提供的REST的路由

有了定义的路由，我们现在到了定义统计视图片段的位置，这需要在div里的几个链接，如清单12.16所示。
```ruby
代码清单 12.16: A partial for displaying follower stats.
# app/views/sha红色/_stats.html.erb
 <% @user ||= current_user %>
<div class="stats">
  <a href="<%= following_user_path(@user) %>">
    <strong id="following" class="stat">
      <%= @user.following.count %>
    </strong>
    following
  </a>
  <a href="<%= followers_user_path(@user) %>">
    <strong id="followers" class="stat">
      <%= @user.followers.count %>
    </strong>
    followers
  </a>
</div>
```
因为我们将包含用户显示页面和主页，清单12.16的第一行使用
```ruby
<% @user ||= current_user %>
```
来取得正确的用户。
如在旁注8.1里讨论的，这没有什么当@user不是nil（如在个人信息页面），但是当他是（如在主页）它设置@user到当前用户。注意following/follower数量被计算通过使用关联的
```ruby
@user.following.count
```
和
```ruby
@user.followers.count
```
比较这些和清单11.23里的微博计数，在那里我们写
```ruby
@user.microposts.count
```
来计数微博。如同那个情况，Rails为了效率直接在数据库计算数量。

最后值得一提的是在一些要素上的CSS id的显示，如在
```ruby
<strong id="following" class="stat">
...
</strong>
```
这是为了在12.2.5节里Ajax实现的利益，使用它们唯一的id读取要素。

有了视图片段，在主页包含就容易了，如清单12.17所示。
```ruby
代码清单 12.17: Adding follower stats to the Home page.
# app/views/static_pages/home.html.erb
 <% if logged_in? %>
  <div class="row">
    <aside class="col-md-4">
      <section class="user_info">
        <%= render 'sha红色/user_info' %>
      </section>
      <section class="stats">
        <%= render 'sha红色/stats' %>
      </section>
      <section class="micropost_form">
        <%= render 'sha红色/micropost_form' %>
      </section>
    </aside>
    <div class="col-md-8">
      <h3>Micropost Feed</h3>
      <%= render 'sha红色/feed' %>
    </div>
  </div>
<% else %>
  .
  .
  .
<% end %>
```
为了样式化统计，我们添加一些SCSS，如显示在清单12.18里（在这张里所有的样式代码包含）。在图12.11里显示>>

=>结果的主页。
```ruby
代码清单 12.18: SCSS for the Home page sidebar.
# app/assets/stylesheets/custom.css.scss
 .
.
.
/* sidebar */
.
.
.
.gravatar {
  float: left;
  margin-right: 10px;
}

.gravatar_edit {
  margin-top: 15px;
}

.stats {
  overflow: auto;
  margin-top: 0;
  padding: 0;
  a {
    float: left;
    padding: 0 10px;
    border-left: 1px solid $gray-lighter;
    color: gray;
    &:first-child {
      padding-left: 0;
      border: 0;
    }
    &:hover {
      text-decoration: none;
      color: blue;
    }
  }
  strong {
    display: block;
  }
}

.user_avatars {
  overflow: auto;
  margin-top: 10px;
  .gravatar {
    margin: 1px 1px;
  }
  a {
    padding: 0;
  }
}

.users.follow {
  padding: 0;
}

/* forms */
.
.
.
```
![图12.11：带关注统计的主页](https://softcover.s3.amazonaws.com/636/ruby_on_rails_tutorial_3rd_edition/images/figures/home_page_follow_stats_3rd_edition.png)

我们将渲染统计视图片段在个人信息页面一会，但是首先让我们为follow/unfollow按钮创建视图片段，如清单12.19所示。
```ruby
代码清单 12.19: A partial for a follow/unfollow form.
# app/views/users/_follow_form.html.erb
 <% unless current_user?(@user) %>
  <div id="follow_form">
  <% if current_user.following?(@user) %>
    <%= render 'unfollow' %>
  <% else %>
    <%= render 'follow' %>
  <% end %>
  </div>
<% end %>
```
这处理推迟了follow和unfollow视图片段真正工作外没什么，它们需要Relationship资源新的路由，我们遵循Microposts资源的例子（清单11.29），如在清单12.20里所见。
```ruby
代码清单 12.20: Adding the routes for user relationships.
# config/routes.rb
 Rails.application.routes.draw do
  root                'static_pages#home'
  get    'help'    => 'static_pages#help'
  get    'about'   => 'static_pages#about'
  get    'contact' => 'static_pages#contact'
  get    'signup'  => 'users#new'
  get    'login'   => 'sessions#new'
  post   'login'   => 'sessions#create'
  delete 'logout'  => 'sessions#destroy'
  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :microposts,          only: [:create, :destroy]
  resources :relationships,       only: [:create, :destroy]
end
```
# follow/unfollow视图片段自己显示在清单12.21里和清单12.22里。
```ruby
代码清单 12.21: A form for following a user.
# app/views/users/_follow.html.erb
 <%= form_for(current_user.active_relationships.build) do |f| %>
  <div><%= hidden_field_tag :followed_id, @user.id %></div>
  <%= f.submit "Follow", class: "btn btn-primary" %>
<% end %>
```
```ruby
代码清单 12.22: A form for unfollowing a user.
# app/views/users/_unfollow.html.erb
 <%= form_for(current_user.active_relationships.find_by(followed_id: @user.id),
             html: { method: :delete }) do |f| %>
  <%= f.submit "Unfollow", class: "btn" %>
<% end %>

```

这两个表格都使用了form_for来操作Relationship模型对象；主要的不同是清单12.21建立了一个new
relationship，然而清单12.22查找存在的关系。自然地，表单发送一个POST请求到Relationship控制器来create一个relationship，然而后者发送一个DELETE请求到destroy一个relationship。（我们将在12.2.4节里写这些动作）。最后，你将注意到关注表单没有内容只有按钮，但是它扔需要发送followed_id到控制器。我们完成这个使用hidden_field_tag方法在清单12.21，产生了HTML表单
```ruby
<input id="followed_id" name="followed_id" type="hidden" value="3" />
```
如我们在10.2.4节所见(清单10.50），隐藏的input标签在网页上放置相关的信息没有在浏览器里显示。

我们现在能包含follow表单和following统计在用户个人信息页面通过简单地渲染视图片段，如清单12.23里所示。带follow和unfollow按钮，各自地，显示在图12.12里和图12.13里。
```ruby
代码清单 12.23: Adding the follow form and follower stats to the user profile
page.
# app/views/users/show.html.erb
 <% provide(:title, @user.name) %>
<div class="row">
  <aside class="col-md-4">
    <section>
      <h1>
        <%= gravatar_for @user %>
        <%= @user.name %>
      </h1>
    </section>
    <section class="stats">
      <%= render 'sha红色/stats' %>
    </section>
  </aside>
  <div class="col-md-8">
    <%= render 'follow_form' if logged_in? %>
    <% if @user.microposts.any? %>
      <h3>Microposts (<%= @user.microposts.count %>)</h3>
      <ol class="microposts">
        <%= render @microposts %>
      </ol>
      <%= will_paginate @microposts %>
    <% end %>
  </div>
</div>
```
![图12.12：带follow按钮的个人用户页面（/users/2）](https://softcover.s3.amazonaws.com/636/ruby_on_rails_tutorial_3rd_edition/images/figures/profile_follow_button_3rd_edition.png)
![图12.13：带unfollow按钮的用户个人信息页（/users/5)](https://softcover.s3.amazonaws.com/636/ruby_on_rails_tutorial_3rd_edition/images/figures/profile_unfollow_button_3rd_edition.png)

我们将很快就让这些按钮工作--实际上，我们将用两种方法完成，标准的方法（12.2.4节）和使用Ajax（12.2.5节）--但是收效我们通过创建following和follower页面来完成HTML界面。

### 12.2.3 following和follower页面
显示被关注的用户和关注着将像一个用户个人信息页面和用户主页（9.3.1节）的混合体，带侧边栏的用户信息（包含following统计）和一列用户。另外，我们将包含一个很小的个人信息图片在侧边栏里。页面模型匹配这些要求显示在图12.14里（following）和图12.15（followers）。
![图12.14：用户following页面的的模型](https://softcover.s3.amazonaws.com/636/ruby_on_rails_tutorial_3rd_edition/images/figures/following_mockup_bootstrap.png)
![图12.15：用户关注着页面的页面模型](https://softcover.s3.amazonaws.com/636/ruby_on_rails_tutorial_3rd_edition/images/figures/followers_mockup_bootstrap.png)

我们第一步是让following和follower链接工作。我们将遵循Twitter的引导，让两个页面都需要用户登陆。如在先前最多的读取控制例子里，我们将先写测试，如在清单12.24里所示。
```ruby
代码清单 12.24: Tests for the authorization of the following and followers pages.
红色
# test/controllers/users_controller_test.rb
 require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end
  .
  .
  .
  test "should redirect following when not logged in" do
    get :following, id: @user
    assert_redirected_to login_url
  end

  test "should redirect followers when not logged in" do
    get :followers, id: @user
    assert_redirected_to login_url
  end
end
```
实现的唯一花招部分就是意识到我们需要添加两个新的动作到Users控制器。依据在清单12.15里定义的路由，我们需要命名为following和followers。每个动作需要设置标题、查找用户、取回@user.following或@user.followers（在分页里的表单），然后渲染页面。结果显示在清单12.25里。
```ruby
代码清单 12.25: The following and followers actions.
# app/controllers/users_controller.rb
 class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy,
                                        :following, :followers]
  .
  .
  .
  def following
    @title = "Following"
    @user  = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user  = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private
  .
  .
  .
end
```
如我们在整个这个指南里所见，通常Rails的惯例是隐式地渲染相应动作的模板，如在show动作的最后渲染show.html.erb。相反，在清单12.25里的两个动作创建显式地调用render，在这里渲染名为show_follow的视图，我们必须创建它。为了这个普通视图的的原因是ERB几乎相同的，清单12.26覆盖了两者。
```ruby
代码清单 12.26: The show_follow view used to render following and followers.
# app/views/users/show_follow.html.erb
 <% provide(:title, @title) %>
<div class="row">
  <aside class="col-md-4">
    <section class="user_info">
      <%= gravatar_for @user %>
      <h1><%= @user.name %></h1>
      <span><%= link_to "view my profile", @user %></span>
      <span><b>Microposts:</b> <%= @user.microposts.count %></span>
    </section>
    <section class="stats">
      <%= render 'sha红色/stats' %>
      <% if @users.any? %>
        <div class="user_avatars">
          <% @users.each do |user| %>
            <%= link_to gravatar_for(user, size: 30), user %>
          <% end %>
        </div>
      <% end %>
    </section>
  </aside>
  <div class="col-md-8">
    <h3><%= @title %></h3>
    <% if @users.any? %>
      <ul class="users follow">
        <%= render @users %>
      </ul>
      <%= will_paginate %>
    <% end %>
  </div>
</div>
```
在清单12.25里的动作从清单12.26的两种环境渲染视图，“following”和“followers”，结果显示在图12.16和图12.17.注意使用当前用户没什么在上面的代码，所以同样的链接对其他用户也工作，如图12.18所示。
![图12.16：显示所给用户正关注的用户](https://softcover.s3.amazonaws.com/636/ruby_on_rails_tutorial_3rd_edition/images/figures/user_following_3rd_edition.png)

![图12.17：显示所给用户的关注者](https://softcover.s3.amazonaws.com/636/ruby_on_rails_tutorial_3rd_edition/images/figures/user_followers_3rd_edition.png)
![图12.18：显示不同用户的关注者](https://softcover.s3.amazonaws.com/636/ruby_on_rails_tutorial_3rd_edition/images/figures/diferent_user_followers_3rd_edition.png)

既然我们已经完成了following和follower页面，我们将写几个短的集成测试来确认他们的行为。他们被设计是正常的检查，不是全面的。确实，如在5.3.4节提到的，全面测试像HTML结果可能是易碎的，因此起反作用。我们的计划在following/followers页面是检查显示的数目是正确的，显示在页面的URL是正确的。

为了开始，我们将如往常一样写集成测试：
```ruby
$ rails generate integration_test following
      invoke  test_unit
      create    test/integration/following_test.rb
```
接下来，我们需要组装一些测试数据，我们可以通过田间一些关系fixture来创建following/follower关系。回忆11.2.3节，我们能使用代码像：
```ruby
orange:
  content: "I just ate an orange!"
  created_at: <%= 10.minutes.ago %>
  user: michael
```
来把所给用户和微博相关联起来。具体来说，我们能写
```ruby
user: michael
```
替代
```ruby
user_id: 1
```
应用这个想法到关系fixture，给出关联在青岛12.27里。
```ruby
代码清单 12.27: Relationships fixtures for use in following/follower tests.
# test/fixtures/relationships.yml
 one:
  follower: michael
  followed: lana

two:
  follower: michael
  followed: mallory

three:
  follower: lana
  followed: michael

four:
  follower: archer
  followed: michael
```
在清单12.27里的fixture首先安排Michael关注Lana和Mallory，然后安排Michael被Lana和Archer关注。为了测试正确的数量，我们可以使用同样的assert_match方法我们在在清单11.27使用的来测试用户个人信息页面微博数量的显示。为正确的链接添加断言产生显示在清单12.28里的测试。
```ruby
代码清单 12.28: Tests for following/follower pages. 绿色
# test/integration/following_test.rb
 require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    log_in_as(@user)
  end

  test "following page" do
    get following_user_path(@user)
    assert_not @user.following.empty?
    assert_match @user.following.count.to_s, response.body
    @user.following.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "followers page" do
    get followers_user_path(@user)
    assert_not @user.followers.empty?
    assert_match @user.followers.count.to_s, response.body
    @user.followers.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end
end
```
在清单12.28里，注意我们包含了断言
```ruby
assert_not @user.following.empty?
```
这是确认
```ruby
@user.following.each do |user|
  assert_select "a[href=?]", user_path(user)
end
```
不是[空洞true](https://en.wikipedia.org/wiki/Vacuous_truth)(followers也相似）
测试集现在应该是绿色的：
```ruby
代码清单 12.29: 绿色
$ bundle exec rails test
```
### 12.2.4 普通方法可用的关注按钮
既然我们的视图可用了，是时候让follow/unfollow按钮工作了。因为following和unfollowing需要创建和删除关系，我们需要Relationships控制器，我们如往常生成
```ruby
$ rails generate controller Relationships
```
如我们在清单12.31里所见，需要读取控制在Relationships控制器动作不会更重要，但是我们仍将跟随我们之前的实践尽早得加强安全模型。具体来说，我们将检查在Relationships控制器里需要登陆用户的读取动作（因此重定向到登陆页面），然而也不改变Relationship数量，如清单12.30所示。
```ruby
代码清单 12.30: Basic access control tests for relationships. 红色
# test/controllers/relationships_controller_test.rb
 require 'test_helper'

class RelationshipsControllerTest < ActionController::TestCase

  test "create should require logged-in user" do
    assert_no_difference 'Relationship.count' do
      post :create
    end
    assert_redirected_to login_url
  end

  test "destroy should require logged-in user" do
    assert_no_difference 'Relationship.count' do
      delete :destroy, id: relationships(:one)
    end
    assert_redirected_to login_url
  end
end
```
我们让清单12.30里的测试通过，通过添加logged_in_user前置过滤（清单12.31）。
```ruby
代码清单 12.31: Access control for relationships. 绿色
# app/controllers/relationships_controller.rb
 class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
  end

  def destroy
  end
end
```
为了follow和unfollow按钮工作，我们需要做的是查找用户关联的followed_id在相应表单里（例如清单12.21或者清单12.22)，然后使用合适的follow和unfollow方法从清单12.10里。完整的实现显示在清单12.32里。
```ruby
代码清单 12.32: The Relationships controller.
# app/controllers/relationships_controller.rb
 class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    user = User.find(params[:followed_id])
    current_user.follow(user)
    redirect_to user
  end

  def destroy
    user = Relationship.find(params[:id]).followed
    current_user.unfollow(user)
    redirect_to user
  end
end
```
我们能从清单12.32里看见为什么上面提到的安全问题是很小的：假如未登陆用户直接点击（例如使用像curl一样的命令行工具），current_user将是nil，在两种请求，动作的第二行将抛出例外，导致错误但是不会对应用程序或数据有所伤害。不过，最好不要依赖，所以我们采取额外的步骤，添加额外的安全层。

有了那个，核心follow/unfollow函数完成了，任何用户可以follow或者unfollow别的用户，如你能通过在你的浏览器里相应的按钮。（我们将写集成测试来确认在12.2.6节的行为）结果的following用户#2显示在图12.19和图12.20.

![图12.19：未关注的用户](https://softcover.s3.amazonaws.com/636/ruby_on_rails_tutorial_3rd_edition/images/figures/unfollowed_user.png)
![图12.20：关注未关注的用户的结果](https://softcover.s3.amazonaws.com/636/ruby_on_rails_tutorial_3rd_edition/images/figures/unfollowed_user.png)

### 12.2.5 带Ajax的工作流按钮
尽管我们的用户following实现完成了如表明的，我们在开始状态feed之前有一点需要装饰一下。你可能已经注意到在12.2.4节create方法和destroy动作在Relationships控制器里简单滴重定向会原始的个人信息页面。换句话说，用户在别的用户的个人信息页面的开始，关注别的用户，被立即重定向会原始的页面。问究竟为什么用户需要离开页面是很合理的。

这恰好是通过Ajax解决的问题，我们允许web页面来异步发送清单到服务器，不必离开页面。因为添加Ajax到web表单是普通的时间，Rails常Ajax实现更容易。确实，更新follow/unfollow表单片段是很小的；只是改变
```ruby
form_for
```
到
```ruby
form_for ..., remote: true
```

Rails会自动使用Ajax。更新的视图片段显示在清单12.33里和清单12.34里。
```ruby
代码清单 12.33: A form for following a user using Ajax.
# app/views/users/_follow.html.erb
 <%= form_for(current_user.active_relationships.build, remote: true) do |f| %>
  <div><%= hidden_field_tag :followed_id, @user.id %></div>
  <%= f.submit "Follow", class: "btn btn-primary" %>
<% end %>
```
```ruby
代码清单 12.34: A form for unfollowing a user using Ajax.
# app/views/users/_unfollow.html.erb
 <%= form_for(current_user.active_relationships.find_by(followed_id: @user.id),
             html: { method: :delete },
             remote: true) do |f| %>
  <%= f.submit "Unfollow", class: "btn" %>
<% end %>
```
实际被ERB生成的HTML不是特别相关，但是你可能好奇，所以这里是大概的偷窥（细节会不同）：
```ruby
<form action="/relationships/117" class="edit_relationship" data-remote="true"
      id="edit_relationship_117" method="post">
  .
  .
  .
</form>
```
在表单标签里设置变量data-remote="true",告诉Rails允许表单被Javascript处理。通过使用简单HTML属性替换插入的完整的Javascript代码（在在之前版本的Rails）Rails遵循了[不招摇的Javascript](http://railscasts.com/episodes/205-unobtrusive-javascript)哲学。

已经更新了表单，我们现在需要安排Relationships控制器响应Ajax请求。我们可以使用respond_to方法来做这个，响应合适地依靠请求的类型。常用的模式看起来像这个：
```ruby
respond_to do |format|
  format.html { redirect_to user }
  format.js
end
```
这个语法潜在第困扰人，理解上面的代码仅会有一行被执行是重要地。（在这句，respond_to更像if-then-else语句比起顺序行的系列）。事情Relationship控制到响应Ajax需要添加respond_to如清单12.32里的create和destroy动作。结果显示在清单12.35里。注意局部变量user和实例变量@user;在青岛12.32里不需要实例变量，但是在清单12.33和12.34里是必要的。
```ruby
代码清单 12.35: Responding to Ajax requests in the Relationships controller.
# app/controllers/relationships_controller.rb
 class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end
end
```

在清单12.35里的动作优雅地降级了，这意味着它们在不支持Javascript的浏览器里工作的很好（尽管一点配置是必要的，如清单12.36里所示）
```ruby
代码清单 12.36: Configuration needed for graceful degradation of form submission.
# config/application.rb
 require File.expand_path('../boot', __FILE__)
.
.
.
module SampleApp
  class Application < Rails::Application
    .
    .
    .
    # Include the authenticity token in remote forms.
    config.action_view.embed_authenticity_token_in_remote_forms = true
  end
end
```
换句话说，我们仍然正确地响应当启用Javascript。在这个Ajax请求的例子，Rails自动调用Javascript内嵌Ruby（.js.erb)文件用和动作同样的名字，例如，create.js.erb或者destroy.js.erb。如你可能猜到的，这样的文件允许混合Javascript和内嵌Ruby到执行动作在当前页面。它是这些问题我们需要创建和编辑为了更新用户个人信息页面在被关注和取消关注。

在JS-ERB文件里，Rails自动地提供jQuery Javascript辅助方法来使用[文档对象模型（DOM）](http://www.w3.org/DOM/)操作页面。jQuery库（我们在11.4.2节里见到——提供大量的方法为操作DOM，但是这里我们仅需要两个。首先，我们需要知道依据唯一的CSS id读取DOM元素的美元符号。例如，为了操作follow_form要素，我们将使用语法
```ruby
$("#follow_form")
```
（回忆12.19，这是个div，包装了表单，而不是表单本身）这个语法，被CSS激发，使用#符号来表明是CSS
id。如你可能猜到的，jQuery，像CSS，使用点.来操作类。

我们需要的第二个方法是html，它更新HTML里面的相关的要素有了它的参数的内容。例如，替换完整的follow表单用字符串“foobar”，我们将写
```ruby
$("#follow_form").html("foobar")
```
不像纯的Javascript文件，JS-ERB文件也允许内嵌Ruby的使用，我们应用在create.js.erb文件里更新follow表单用unfollow视图片段（这是成功关注后应该显示的内容）和更新关注者的数量。结果显示在清单12.37里。这使用escape_javascript方法，当插入HTML在文件Javascript文件里转义的结果。
```ruby
代码清单 12.37: The JavaScript embedded Ruby to create a following relationship.
# app/views/relationships/create.js.erb
 $("#follow_form").html("<%= escape_javascript(render('users/unfollow')) %>");
$("#followers").html('<%= @user.followers.count %>');
```
注意行尾的分号，这是从[ALGOL](https://en.wikipedia.org/wiki/ALGOL)继承的语言的特性。

destroy.js.erb文件是相似的（清单12.38）。
```ruby
代码清单 12.38: The Ruby JavaScript (RJS) to destroy a following relationship.
# app/views/relationships/destroy.js.erb
 $("#follow_form").html("<%= escape_javascript(render('users/follow')) %>");
$("#followers").html('<%= @user.followers.count %>');
```
有了那个，你应该导航用户个人信息页面和确认你能关注和取消关注，不需要刷新页面。
