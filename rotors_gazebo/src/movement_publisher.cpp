#include "ros/ros.h"
#include "geometry_msgs/Twist.h"


int main(int argc, char **argv)
{

  ros::init(argc, argv, "talker");

  ros::NodeHandle n;

  // Advertize the publisher on the topic you like
  ros::Publisher pub = n.advertise<geometry_msgs::Twist>("my_topic_name", 1000);

  while (ros::ok())
  {
    /**
     * This is a message object. You stuff it with data, and then publish it.
     */
    geometry_msgs::Twist myTwistMsg

    // Here you build your twist message
    myTwistMsg.linear.x = 1;
    myTwistMsg.linear.y = 2;
    myTwistMsg.linear.z = 3;

    ros::Time beginTime = ros::Time::now();
    ros::Duration secondsIWantToSendMessagesFor = ros::Duration(3); 
    ros::Time endTime = secondsIWantToSendMessagesFor + beginTime;
    while(ros::Time::now() < endTime )
    {
        pub.publish(myTwistMsg);

        // Time between messages, so you don't blast out an thousands of 
        // messages in your 3 secondperiod
        ros::Duration(0.1).sleep();
    }

  }

  return 0;
}