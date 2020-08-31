# Huawei Cloud Auto Scaling Demo

Step-by-step how to use Huawei Cloud Autoscaling + ELB

Abstract：Auto Scaling (AS) is a somewhat cool feature which is almost the standard of cloud providers. It is a service that automatically adjusts service resources based on your service requirements and configured AS policies.

- [Description](#description)

- [Prerequisites](#prerequisites)

- [Lifecycle](#lifecycle)

- [Demo Web Application](#demo-web-application)

- [Auto Scaling Demo](#auto-scaling-demo)

![main picture](/images/main.jpg)

## Description
In this auto scaling demo, I did the following:

- Create a simple **web application** which will print the ECS instance IP address on which it runs

- Create a **private image** with the pre-installed web application and some scripts to generate CPU/memory load to the ECS instance

- Create an **ELB instance** and a listener on it. AS service will cooperate with the ELB to register a newly created ECS instance to it, and de-register a removed ECS instance from it

- Create an **auto scaling group** with 2 alarm policies set:
    - *as-policy-cpu-high:* If average CPU usage Max. > 80%, then add 1 instance
    - *as-policy-cpu-low:* If average CPU usage Max. < 35%, then reduce 1 instance

The auto scaling demo is a very comprehensive example, since it relates to the following services:

- [ECS:](https://support.huaweicloud.com/intl/en-us/ecs/index.html) Elastic Cloud Server (ECS) instances are added/Removed from [AS](https://support.huaweicloud.com/intl/en-us/as/index.html) Group by scaling actions

- [IMS:](https://support.huaweicloud.com/intl/en-us/ims/index.html) Create a private image through Image Management Service (IMS), with web application deployed, ECS instances are created by it

- [CES:](https://support.huaweicloud.com/intl/en-us/ces/index.html) If an alarm-triggering policy is configured, AS works together with Cloud Eye Service (CES) to trigger scaling actions in the event that a specified alarm is generated

- [ELB:](https://support.huaweicloud.com/intl/en-us/elb/index.html) After Elastic Load Balance (ELB) is configured, AS automatically adds ECS instances to or removes ECS instances from the ELB service in a scaling action

- [SMN:](https://support.huaweicloud.com/intl/en-us/smn/index.html) Simple Message Notification (SMN) can push messages about auto scaling group activities to users so they can get the current status of auto scaling group in a timely manner

- [CTS:](https://support.huaweicloud.com/intl/en-us/cts/index.html) With Cloud Trace Service (CTS), you can record the activities of the auto scaling events, which can be used for future inquiries, audit and backtracking


## Prerequisites
- Huawei Cloud Account: [Huawei Cloud](https://intl.huaweicloud.com/en-us/)
    -   **Notes** ：This article is **NOT** a replacement of User Guide of a certain service. That is to say, you have to familiar with basic Huawei Cloud operations, such as how to create a private image from an ECS instance, how to create an ELB instance and a listener, etc. If you do not know how to do these, please refer to the User Guide of a certain service: [Huawei Cloud Help Center](https://support.huaweicloud.com/intl/en-us/index.html)

We assume you have created your own resources, the resources created below on Huawei Cloud are references for this guide:

1. VPC (vpc-demo)
    ![VPC](/images/vpc-demo.jpg)

2. Subnet (subnet-1)
    ![Subnet](/images/subnet-demo.jpg)

3. Security Group (sg-demo)
    ![Security Group](/images/sg-demo01.jpg)
   Security Group (sg-demo rules) 
    ![Security Group Rules](/images/sg-demo02.jpg)

4. Private Image (ecs-demo-img)
    ![System ECS Image](/images/img-demo.jpg)

5. ELB (elb-demo)
    ![ELB](/images/elb-demo.jpg)

6. ELB Listener (listener-demo)
    ![Listeners](/images/listener-demo.jpg)

7. ECS instace with Ubuntu Server
    ![ECS](/images/ecs-demo.jpg)


## Lifecycle
The lifecycle of an instance in an AS group starts when it is created and ends when it is removed from the AS group.

The instance lifecycle changes as shown in figure below.
![lifecycle](/images/lifecycle.jpg)

In trigger conditions 2 and 4, a scaling action is automatically triggered to change the instance status.

More details about scaling actions and triggers can be shown in the table below:
![lifecycle](/images/lifecycle-table.jpg)

###### Consecutive Occurrences
- Set the number of consecutive times the threshold must be exceeded for the alarm to be generated. If Occurrences is set to 3, the alarm will be generated after the threshold is exceeded for the third consecutive time.

###### Cooldown Period
- The cooldown period starts after each scaling action is complete. During the cooldown period, scaling actions triggered by alarms will be denied. Scheduled and periodic scaling actions are not restricted.

Before an instance is added to the AS group, it requires 2 to 3 minutes to execute the configuration script to install and configure applications. The time varies depending on many factors, such as the instance specifications and startup scripts. Therefore, if an instance is put into use without cooldown after started, the system will continuously increase instances until the load decreases. After the new instances take over services, the system detects that the load is too low and decreases instances in the AS group. A cooldown prevents the AS group from repeatedly triggering unnecessary scaling actions.

**The following uses an example to introduce the cooling principles:**

When a traffic peak occurs, an alarm policy is triggered. In this case, AS automatically adds an instance to the AS group to help handle the added demands. However, it takes several minutes for the instance to start. After the instance is started, it takes a certain period of time to receive requests from ELB. During this period, alarms may be triggered continuously. As a result, an instance is added each time an alarm is triggered. If you set a cooldown time, after an instance is started, AS stops adding new instances according to the alarm policy until the specified period of time (300 seconds by default) passes. Therefore, the newly started instance has time to start processing application traffic. If an alarm is triggered again after the cooldown period elapses, AS starts another instance and the cooldown period takes effect again.


###### Configuring an Instance Removal Policy
When instances are automatically removed from your AS group, the instances that are not in the currently used AZs will be removed first. Besides, AS will check whether instances are evenly distributed in the currently used AZs. If the number of instances in an AZ is greater than that in other AZs, AS attempts to balance load between AZs when removing instances. If the load between AZs is balanced, AS removes instances following the pre-configured instance removal policy.

AS supports the following instance removal policies:

- **Oldest instance:** The oldest instance is removed from the AS group first. Use this policy if you want to replace old instances by new instances in an AS group.

- **Newest instance:** The latest instance is removed from the AS group first. Use this policy if you want to test a new AS configuration and do not want to retain it.

- **Oldest instance created from oldest AS configuration:** The oldest instance created based on the oldest configuration is removed from the AS group first. Use this policy if you want to update an AS group and delete the instances created based on early AS configurations gradually.

- **Newest instance created from oldest AS configuration:** The latest instance created based on the oldest configuration is removed from the AS group first.

- **NOTE:** A manually added ECS is removed in the lowest priority. AS does not delete a manually added ECS when removing it. If multiple manually added ECSs must be removed, AS preferentially removes the earliest-added ECS.


## Demo Web Application

1. Please refer to [Web app guide](webapp.md) to install nginx and deploy *as-demo app* on your Ubuntu ECS instance.

- **NOTE:** In this example, I used Ubuntu 18.04. However, it is not a mandatory, you can use your own Operating Sytem and application server version.

2. Bind an [EIP](https://support.huaweicloud.com/intl/en-us/eip/index.html) to your ECS instance and try to access your web server. If you can see a web page with Auto Scaling Demo displayed and your IP address, congratulations, your web application is successfully deployed.

3. stop the ECS instance, and make a private image from this ECS instance. In this example, I made a private image named ecs-demo-img.
 
## Auto Scaling Demo
1. ##### Create **AS Group**:

An *AS group* consists of a collection of ECS instances and *AS policies* that have similar attributes and apply to the same application scenario. An AS group is the basis for enabling or disabling AS policies and performing scaling actions. The pre-configured AS policy automatically adds or deletes instances to or from an AS group, or maintains a fixed number of instances in an AS group.

Go to *Auto Scaling* and create an AS group. I used some information in *Prerequisites section*, please adjust the parameters according to your own environment.

- **NOTE:** I choose *Use ELB* in this example, so all the ECS instances created will be added to ELB as backend ECS instances.

![Create Autoscaling Group](/images/create-as-group-01.jpg)

![Create Autoscaling Group](/images/create-as-group-02.jpg)

![Create Autoscaling Group](/images/create-as-group-03.jpg)
 
As you can see in the pictures above it is mandatory to create an "**AS Configuration**"
![AS Configuration](/images/as-configuration-mandatory.jpg)
So let's create our configuration before finish our AS Group configuration.

- **Tip:** I recommend you to disable your **AS Group** and go all the way down to finish all configuration needed and just enable it when it is really necessary, otherwise it will create ECS instances and you will start paying for resources you are not using right a way.

2. ##### Create **AS Configuration**:

An AS configuration specifies the specifications of the ECSs to be added to an **AS group**.
The most important thing is to choose the Image which is the private image you created.
![AS Configuration](/images/my-config-01.jpg)
![AS Configuration](/images/my-config-02.jpg)
![AS Configuration](/images/my-config-03.jpg)
![AS Configuration](/images/my-config-04.jpg)

If everything is correct, click **Create Now**.
 
After successful creation, you can see the newly created AS Configuration in the list and now need to go back to your **AS Group creation** to finish the creation of the AS Group with the selected AS Configuration.
 
3. ##### Add Policy:

A scaling policy specifies the conditions for triggering a scaling action as well as the triggered operation. If the conditions are met, a scaling action is triggered to perform the required operation.

A policy can be of Alarm, Scheduled, or Periodic type.

- **Alarm:** AS automatically increases or decreases the number of ECS instances in an AS
group or sets the number of ECS instances to a specified value if Cloud Eye (CES)
generates an alarm for a configured metric, such as CPU usage.
![Add AS Policy Alarm](/images/add-as-policy-alarm.jpg)

- **Periodic:** AS increases or decreases the number of ECS instances in an AS group or sets the number of ECS instances to a specified value at a configured interval, such as one
day, one week, or month.
![Add AS Policy Periodic](/images/add-as-policy-periodic.jpg)

- **Scheduled:** AS automatically increases or decreases the number of ECS instances in an
AS group or sets the number of ECS instances to a specified value at a specified time
![Add AS Policy Schedule](/images/add-as-policy-schedule.jpg)


To create an **AS Policy** you need to go to **AS Group Configuration** detailed page (picture below)
![Add AS Policy](/images/as-group-details.jpg)

And then select **AS Policies** tab and click **Add AS Policy**
![Add AS Policy](/images/as-policy-demo.jpg)

In my example, I will create two policies to simulate an increase of load and add instances to serve my application or decrease load.
You can see the configuration of my two policies below:

- Policy **as-policy-demo-up** tells the AS Group: If the average CPU Usage of AS Group is higher or equal 80%, then add 1 instance

![Add AS Policy](/images/as-policy-demo-up.jpg)
 
- Policy **as-policy-demo-down** tells the AS Group: If the average CPU Usage of AS Group is lower or equal 30%, then reduce 1 instance

![Add AS Policy](/images/as-policy-demo-down.jpg)


- **NOTE:** In this example I used CPU Usage as a trigger, you can created other alarm/schedule/periodic to trigger scaling action.

4. ##### AS Group Summary
Go back to AS Group you can see as-group-demo is related to as-config-demo.
![AS Group Summary](/images/as-group-summary.jpg)

The current status of AS Group as-group-demo is **Disabled**, please click **Enable** in the Operation column to enable it. Make sure your expected and minimum ECS are set to **0**

5. ##### AS Group Instance
Click AS Group name as-group-demo, you will se an overview of your Autoscaling configuration, click **Modify** and change configuration to add 1 or more ECS to your AS. In my example I added two ECS and changed cooldown period to 100 (If you have doubt about how to set cooldown period, go to [Cooldown Period section](#cooldown-period))
![Expected , Minimum & Cooldown](/images/expected-minimum02.jpg)

You can see an instances is in Initializing status.
 
Wait for some moments, the instance status will be Normal. 
 
6. ##### ELB Backend ECS Instance - fresh
Check the ELB instance elb-demo and choose Backend ECS tab, you can see an ECS instance is registered to it. If you see the Health Check is Abnormal, do not worry, wait for some minutes. Eventually the backend ECS instance’s Health Check will be Normal.
 
7. ##### Access Web Application
Now, it’s time to access the web application. Open a web browser and input: http://<ELB Service IP address>/

**NOTE:** Please use the correct ELB Service IP address in your environment. For this example, the url is: http://www.hwcping.com.br . If there is nothing wrong, you will see the following web page. Check the IP Address it printed if the same as your ECS instance private IP address.
 
8. ##### Make sure CPU high policy is enabled
Now, go to AS Group -> Policy to make sure the polices created are Enabled. If not, please enable them.
 
9. ##### Spike's CPU
If you follow me util here, **Congratulations!** 

Now it’s time to show how auto scaling really works.

First, login to one of your ECS instance, and put some CPU load to it. 
(I used **stress** tool, but you can use your own prefered tool)
On your ECS terminal, run the command below:
```
stress --cpu 8 --io 3 --vm 2 --vm-bytes 256M --timeout 15m
```

Then monitor its CPU Usage. If it is under 80%, then increase the parameters option.
 
Now, wait for some time (at least 5 minutes which is the default monitor interval), you can see a new instance is initializing. Wait for some minutes, the Health Status will be Normal.
 
10. ##### ELB Backend ECS Instances - newly
Go to ELB elb-demo and choose Backend ECS, you will see the newly created ECS instance is registered to the ELB. If the “Health Check” status is not Normal, wait for some minutes.
 
11. ##### Access Web Application after Scaling
Now, it’s time to check auto scaling result. Open a web browser and input: http://<ELB Service IP address>, mark the checkbox to auto refresh, you will see the IP Address changes each time when refresh.
 
12. ##### AS Group CPU Low Reduce 1 Instance
Wait or kill your stress tool execution (run for 15 minutes). After the tool stop running, wait for some time (at least 5 minutes which is the default monitor interval), you will see the ECS instances in AS Group as-group-demo reduce 1 and there is only 2 instances(expected instance number is 2) running in the AS Group.
 
When CPU usage is below 35% for some time (Monitoring Interval * Consecutive Occurrences), AS Group will reduce 1 instance.