                                       -- **Social Media Project** --


                                       -- **Objective Questions** --

-- 1) Are there any tables with duplicate or missing null values? If so, how would you handle them? --
-- comments table - checking duplicate 
select distinct id from comments;
select id, count(*) from comments
group by 1
having count(*) >1;

select distinct user_id from comments;
select user_id from comments;

select distinct photo_id from comments;
select photo_id from comments;

-- follows table - checking duplicate
select distinct follower_id from follows;
select follower_id from follows;

select distinct followee_id from follows;
select followee_id from follows;

-- likes table - checking duplicate
select distinct user_id from likes;
select user_id from likes

select distinct photo_id from likes;
select photo_id from likes;

-- photo_tags table- checking duplicate
select distinct photo_id from photo_tags;
select photo_id from photo_tags;

select distinct tag_id from photo_tags;
select tag_id from photo_tags;

-- photos table - checking duplicate
select distinct id from photos;
select id from photos;

select image_url from photos;
select distinct image_url from photos;

select distinct user_id from photos;
select user_id from photos;

-- tags table - checking duplicate
select id from tags;
select distinct id from tags;

-- users table - checking duplicate 
select id from users;
select distinct id from users;

select username from users;
select distinct username from users;

-- comments table null checking -- 
select * from comments where comment_text is null;
select * from comments where user_id is null;
select * from comments where photo_id is null;
select * from comments where created_at is null;

-- follows table null checking -- 
select * from follows where follower_id is null;
select * from follows where followee_id is null;
select * from follows where created_at is null;

-- likes table null checking --
select * from likes where user_id is null;
select * from likes where photo_id is null;
select * from likes where created_at is null;

-- photo_tags table null checking -- 
select * from photo_tags where photo_id is null;
select * from photo_tags where tag_id is null;

-- photos table null checking -- 
select * from photos where image_url is null;
select * from photos where user_id is null;

-- tags table null checking -- 
select * from tags where tag_name is null;

-- users table null checking -- 
select * from users where username is null;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
-- 2.What is the distribution of user activity levels (e.g., number of posts, likes, comments) across the user base?--

select distinct u.id AS UserID, u.username,
    coalesce(l.like_count, 0) AS like_count,
    coalesce(c.comment_count, 0) AS comment_count,
    coalesce(p.photo_count, 0) AS photo_count
from users u 
  left join (select distinct user_id, count(*) as like_count from likes group by user_id) l 
   on u.id=l.user_id
  left join (select distinct user_id, count(distinct id) as comment_count from comments group by user_id) c 
   on c.user_id=u.id
  left join (select distinct user_id, count(distinct id) as photo_count from photos group by user_id) p
   on p.user_id=u.id
 order by like_count desc,comment_count desc,photo_count desc
 ;
 
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
 -- 3.	Calculate the average number of tags per post (photo_tags and photos tables). --
 with cte as(
 select p.id as photo_id, count(tag_id) as total_tags from photos p 
 join photo_tags t 
 on p.id=t.photo_id
 group by p.id 
 )
 select avg(total_tags) as avg_num_tags from cte;
 
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
 -- 4. Identify the top users with the highest engagement rates (likes, comments) on their posts and rank them. -- 
 with comments_count as(
select user_id, count(photo_id) as total_comments from comments
group by user_id
), 
likes_count as(
select user_id, count(photo_id) as total_likes from likes
group by user_id
), post_count as(
select user_id, count(id) total_posts from photos
group by user_id
),
user_info as(
select u.id, u.username, p.total_posts, (c.total_comments+l.total_likes) as total_engagement
from users u 
join comments_count c on 
u.id=c.user_id
join likes_count l on 
u.id=l.user_id
join post_count p on
u.id=p.user_id
group by u.id,u.username
)
select id, username,total_posts, total_engagement, 
dense_rank() over(order by total_engagement desc, total_posts asc) as total_engagement_rank from user_info
order by total_engagement desc
limit 10;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 5.	Which users have the highest number of followers and followings? -- 
select u.id,u.username, count(f.follower_id) as total_followers 
from users u 
join follows f on 
u.id=f.follower_id
group by u.id, u.username
order by total_followers desc
limit 5; -- users with highest followers -- 

select u.id,u.username, count(f.followee_id) as total_followings 
from users u 
join follows f on 
u.id=f.followee_id
group by u.id, u.username
order by total_followings desc
limit 5;  -- users with highest followings -- 

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 6.Calculate the average engagement rate (likes, comments) per post for each user. --

with comments_count as(
select user_id, count(photo_id) as total_comments from comments
group by user_id
), 
likes_count as(
select user_id, count(photo_id) as total_likes from likes
group by user_id
), post_count as(
select user_id, count(id) as total_posts from photos
group by user_id
),
user_info as(
select u.id, u.username, p.total_posts, (c.total_comments+l.total_likes) as total_engagement
from users u 
join comments_count c on 
u.id=c.user_id
join likes_count l on 
u.id=l.user_id
join post_count p on
u.id=p.user_id
group by u.id,u.username
)
select id, username,total_posts,total_engagement/total_posts as avg_engagement_rate
from user_info
group by id,username,total_posts
order by avg_engagement_rate desc, total_posts asc
limit 10;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 7.Get the list of users who have never liked any post (users and likes tables) --

select distinct u.id,u.username from users u 
left join likes l on 
u.id=l.user_id
where l.user_id is null;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 8.	How can you leverage user-generated content (posts, hashtags, photo tags) to create more personalized and engaging ad campaigns? -- 

with hashtag as(
select u.id as user_id, u.username, count(distinct t.tag_id) as total_hashtag
from users u 
join photos p on 
u.id=p.user_id
join photo_tags t on 
p.id=t.photo_id 
group by u.id, u.username
), 
phototag as (
select u.id as user_id, u.username, t.tag_name, count(pt.photo_id) as total_phototag, count(p.id) as total_post
from users u 
join photos p on 
u.id=p.user_id
join photo_tags pt on 
p.id=pt.photo_id
join tags t on
pt.tag_id=t.id
group by u.id, u.username, t.tag_name
)
select u.id as user_id,u.username, p.tag_name as hashtag, h.total_hashtag,p.total_phototag, p.total_post,
(h.total_hashtag + p.total_phototag + p.total_post) total_engagement
from users u 
join hashtag h on 
u.id=h.user_id
join phototag p on 
u.id=p.user_id
group by u.id,u.username,p.tag_name
order by total_engagement desc
limit 10;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 9. Are there any correlations between user activity levels and specific content types (e.g., photos, videos, reels)? 
-- How can this information guide content creation and curation strategies?

with photo_counts as (select user_id,count(id) as photo_count
    from photos
    group by user_id),
comment_counts as (select user_id,count(id) as comment_count
    from comments
    group by user_id),
like_counts as (select user_id,count(photo_id) as like_count
    from likes
    group by user_id),
user_activity as (select u.id as user_id,u.username,
        coalesce(pc.photo_count, 0) as photo_count,
        coalesce(cc.comment_count, 0) as comment_count,
        coalesce(lc.like_count, 0) as like_count
    from users u
    left join photo_counts pc on u.id = pc.user_id
    left join comment_counts cc on u.id = cc.user_id
    left join like_counts lc on u.id = lc.user_id)
select user_id,username,photo_count as photos,comment_count as comments,like_count as likes,
    case
        when photo_count > 0 then 'Photo'
        when comment_count > 0 then 'Comment'
        when like_count > 0 then 'Like'
        else 'None'
    end as content_type
from user_activity
order by content_type; 

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 10.	Calculate the total number of likes, comments, and photo tags for each user. -- 

with comments_count as(
select user_id, count(*) as total_comments
from comments 
group by user_id
), 
likes_count as(
select user_id, count(*) as total_likes
from likes
group by user_id
), 
tags_count as(
select p.user_id,p.id,photo_id, count(tag_id) as total_tags
from photo_tags
left join photos p on 
photo_id=p.id
group by p.user_id,photo_id
)
select u.id, u.username, coalesce(c.total_comments,0) as total_comments, coalesce(l.total_likes,0) as total_likes, coalesce(t.total_tags,0) as total_tags
from users u 
left join comments_count c on
u.id=c.user_id
left join likes_count l 
on u.id=l.user_id
left join tags_count t
on u.id=t.user_id
order by total_comments desc, total_likes desc, total_tags desc
limit 15;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 11.	Rank users based on their total engagement (likes, comments, shares) over a month. -- 

with EngagementCounts as (
    select u.id, u.username,
           count(distinct l.user_id) as total_likes,
           count(distinct c.id) as total_comments,
           count(distinct t.tag_id) as total_tags,
           count(distinct l.user_id) + count(distinct c.id) + count(distinct t.tag_id) as total_engagement
    from users u
    left join photos p on u.id = p.user_id
    left join likes l on p.id = l.photo_id and l.created_at >= date_sub(now(), interval 1 month)
    left join comments c on p.id = c.photo_id and c.created_at >= date_sub(now(), interval 1 month)
    left join photo_tags t on p.id = t.photo_id
    group by u.id, u.username
)
select id, username, total_likes, total_comments, total_tags, total_engagement,
       rank() over (order by total_engagement desc) as engagement_rank
from EngagementCounts
order by engagement_rank;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 12.	Retrieve the hashtags that have been used in posts with the highest average number of likes. Use a CTE to calculate the average likes for each hashtag first.--
with Tag_Avg_likes as(
	select t.tag_name, ROUND(avg(likes_count.likes),2) as Avg_likes
    from tags t 
    join photo_tags pt on 
    t.id=pt.tag_id
    join photos p on 
    pt.photo_id=p.id
    join(select photo_id, count(*) as likes
    from likes 
    group by photo_id) as likes_count on p.id=likes_count.photo_id
    group by t.tag_name)
    select tag_name, Avg_likes
    from Tag_Avg_likes
    order by avg_likes desc
    limit 15;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 13.	Retrieve the users who have started following someone after being followed by that person -- 
select u1.username as follower_username
from follows f1
join  follows f2 on 
f1.follower_id = f2.followee_id 
and f1.followee_id = f2.follower_id
join users u1 on f1.follower_id = u1.id
where f1.created_at > f2.created_at;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- *************Subjective Questions************* --

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 1.	Based on user engagement and activity levels, which users would you consider the most loyal or valuable? How would you reward or incentivize these users? --

with user_activity as (select u.id as user_id,u.username,
        ifnull(photo_counts.total_photos, 0) as total_photos,
        ifnull(comment_counts.total_comments, 0) as total_comments,
        ifnull(like_counts.total_likes_given, 0) as total_likes_given,
        ifnull(follower_counts.total_followers, 0) as total_followers,
        ifnull(following_counts.total_following, 0) as total_following,
        (ifnull(photo_counts.total_photos, 0) +
            ifnull(comment_counts.total_comments, 0) +
            ifnull(like_counts.total_likes_given, 0)  +
            ifnull(follower_counts.total_followers, 0)  +
            ifnull(following_counts.total_following, 0) ) as engagement_score
    from users u
    left join(select user_id, count(*) as total_photos from photos group by user_id) photo_counts on u.id = photo_counts.user_id
    left join(select user_id, count(*) as total_comments from comments group by user_id) comment_counts on u.id = comment_counts.user_id
    left join(select user_id, count(*) as total_likes_given from likes group by user_id) like_counts on u.id = like_counts.user_id
    left join(select followee_id as user_id, COUNT(*) as total_followers from follows group by followee_id) follower_counts on u.id = follower_counts.user_id
    left join(select follower_id as user_id, COUNT(*) as total_following from follows group by follower_id) following_counts on u.id = following_counts.user_id),
ranked_users as (select user_id,username,engagement_score,rank() over (order by engagement_score desc) as user_rank
    from user_activity)
select user_id,username,engagement_score,user_rank
from ranked_users
where user_rank = 1;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 2.	For inactive users, what strategies would you recommend to re-engage them and encourage them to start posting or engaging again? -- 

with user_activity as 
(select u.id as user_id,u.username,
        ifnull(photo_counts.total_photos, 0) as total_photos,
        ifnull(comment_counts.total_comments, 0) as total_comments,
        ifnull(like_counts.total_likes_given, 0) as total_likes_given,
        ifnull(follower_counts.total_followers, 0) as total_followers,
        ifnull(following_counts.total_following, 0) as total_following,
        (ifnull(photo_counts.total_photos, 0) +
            ifnull(comment_counts.total_comments, 0) +
            ifnull(like_counts.total_likes_given, 0)  +
            ifnull(follower_counts.total_followers, 0)  +
            ifnull(following_counts.total_following, 0) ) as engagement_score
    from users u
    left join(select user_id, COUNT(*) as total_photos from photos group by user_id) photo_counts on u.id = photo_counts.user_id
    left join(select user_id, COUNT(*) as total_comments from comments group by user_id) comment_counts on u.id = comment_counts.user_id
    left join(select user_id, COUNT(*) as total_likes_given from likes group by user_id) like_counts on u.id = like_counts.user_id
    left join(select followee_id as user_id, COUNT(*) as total_followers from follows group by followee_id) follower_counts on u.id = follower_counts.user_id
    left join(select follower_id as user_id, COUNT(*) as total_following from follows group by follower_id) following_counts on u.id = following_counts.user_id),
ranked_users as (select user_id,username,engagement_score,dense_rank() over (order by engagement_score asc) as user_rank
    from user_activity)
select user_id,username,engagement_score,user_rank
from ranked_users
;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 3.	Which hashtags or content topics have the highest engagement rates? How can this information guide content strategy and ad campaigns? --

select t.tag_name,
    count(pt.photo_id) as total_posts,
    coalesce(sum(likes.total_likes), 0) as total_likes,
    coalesce(sum(comments.total_comments), 0) as total_comments,
    (coalesce(sum(likes.total_likes), 0) + coalesce(sum(comments.total_comments), 0)) / count(pt.photo_id) as average_engagement
from tags t
join photo_tags pt on t.id = pt.tag_id
left join (select photo_id, count(*) as total_likes from likes group by photo_id) likes on pt.photo_id = likes.photo_id
left join (select photo_id, count(*) as total_comments from comments group by photo_id) comments on pt.photo_id = comments.photo_id
group by t.tag_name
order by average_engagement desc
limit 10; 

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 4.	Are there any patterns or trends in user engagement based on demographics (age, location, gender) or posting times? -- 
-- How can these insights inform targeted marketing campaigns? -- 

select date_format(p.created_dat, '%H') as hour_of_day,
    dayname(p.created_dat) as day_of_week,
    count(p.id) as total_posts,
    coalesce(sum(likes.total_likes), 0) as total_likes,
    coalesce(sum(comments.total_comments), 0) as total_comments,
    (coalesce(sum(likes.total_likes), 0) + coalesce(sum(comments.total_comments), 0)) / count(p.id) AS average_engagement
from photos p
left join (select photo_id, count(*) as total_likes from likes group by  photo_id) likes on p.id = likes.photo_id
left join (select photo_id, count(*) as total_comments from comments group by photo_id) comments on p.id = comments.photo_id
group by hour_of_day, day_of_week
order by average_engagement desc;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 5.	Based on follower counts and engagement rates, which users would be ideal candidates for influencer marketing campaigns? -- 
-- How would you approach and collaborate with these influencers? -- 

select u.id as user_id,
    u.username,
    count(f.follower_id) as follower_count,
    coalesce(sum(likes.total_likes), 0) as total_likes,
    coalesce(sum(comments.total_comments), 0) as total_comments,
    coalesce(sum(likes.total_likes), 0) + coalesce(sum(comments.total_comments), 0) as total_engagement,
    case when count(f.follower_id) > 0 then 
        (coalesce(sum(likes.total_likes), 0) + coalesce(sum(comments.total_comments), 0)) / count(f.follower_id)
    else 0 end as engagement_rate
from users u
left join follows f on u.id = f.followee_id
left join (select photo_id, count(*) as total_likes from likes group by photo_id) likes
on u.id = (select user_id from photos where id = likes.photo_id)
left join (select photo_id, count(*) as total_comments from comments group by photo_id) comments 
on u.id = (select user_id from photos where id = comments.photo_id)
group by u.id, u.username
order by engagement_rate desc, follower_count desc
limit 10;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 6.	Based on user behavior and engagement data, how would you segment the user base for targeted marketing campaigns or personalized recommendations? --
select u.id as user_id, u.username,
    coalesce(sum(likes_count), 0) as total_likes,
    coalesce(sum(comments_count), 0) as total_comments,
    coalesce(count(distinct p.id), 0) as total_photos,
    case 
        when coalesce(count(distinct p.id), 0) = 0 then 0 
        else (coalesce(sum(likes_count), 0) + coalesce(sum(comments_count), 0)) / coalesce(count(distinct p.id), 1) 
    end as engagement_rate,
    case 
        when coalesce(count(distinct p.id), 0) = 0 then 'Low'
        when (coalesce(sum(likes_count), 0) + coalesce(sum(comments_count), 0)) / coalesce(count(distinct p.id), 1) > 150 then 'High'
        when (coalesce(sum(likes_count), 0) + coalesce(sum(comments_count), 0)) / coalesce(count(distinct p.id), 1) between 100 and 150 
        then 'Medium'
        else 'Low'
    end as engagement_level
from users u
left join (select user_id, count(*) as likes_count from likes group by user_id) l on u.id = l.user_id
left join (select user_id, count(*) as comments_count from comments group by user_id) c on u.id = c.user_id
left join photos p on u.id = p.user_id
group by u.id, u.username
order by engagement_rate desc;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  

  












 



 
 







