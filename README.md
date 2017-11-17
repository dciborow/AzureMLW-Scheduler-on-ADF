# Run Experiment on ADF

This sample shows how to leverage ADF to run an experiment. 

## Prerequisites
-[Create Azure Machine Learning Preview accounts and install Azure Machine Learning Workbench](https://docs.microsoft.com/en-us/azure/machine-learning/preview/quickstart-installation)

## Create Compute Targets

First, create compute targets for running the parameter sweep: DSVM and optionally, HDInsight Spark Cluster. Select **File**, **Open Command Prompt** and enter following commands to create the compute targets.

Create a Ubuntu baesd DSVM using [these instructions](https://docs.microsoft.com/en-us/azure/machine-learning/data-science-virtual-machine/dsvm-ubuntu-intro#create-your-data-science-virtual-machine-for-linux). Attach it as compute target, and then prepare it by using:

```bash
$ az ml computetarget attach --name <dsvm> --address <dsvm-ip> --username <sshusername> --password <sshpwd> --type remotedocker
```

```bash
$ az ml experiment prepare -c <dsvm>
```

OR

Create HDInsight Spark Cluster using [these instructions](https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-apache-spark-jupyter-spark-sql). Attach it as compute target, and then prepare it by using:

```bash
$ az ml computetarget attach --name <myhdi> --address <myhdi-ssh.azurehdinsight.net> --username <sshusername> --password <sshpwd> --type cluster
```

```bash
$ az ml experiment prepare -c <myhdi>
```


## Run the Model from Local Machine

**Note**: To run sweep_spark.py, you must select DSVM or HDInsight Spark cluster as compute target. The sweep_sklearn.py can run on local Python also.


DSVM run using spark-sklearn

```bash
$ az ml experiment submit -c <dsvm> .\sweep_spark.py
```

HDInsight Spark run using spark-sklearn:

```bash
$ az ml experiment submit -c <myhdi> .\sweep_spark.py
```

## Deploy ADFv2 and other required resources

1. Download and place IaC folder within your AML Workspace project directory.
1. Download and place batch task within your AML Workspace project directory.
1. Open Powershell and execute the following command.
    1. define a prefix for all resources
    1. define a unique string all lower case
    1. Pick region (ADF will deploy to US East regardless)
    1. Git user
    1. Make Git Access Key
    1. VSTS Server
    1. VSTS Account
    1. Git Project Name
    1. Azure Subscription Name
    1. DSVM Compute Target
    1. Path in AML Workbench project to code
    
```
.\IaC\CreateDeployment.ps1 `
    -prefix "<resource prefix>" `
    -unique "<prefix suffix for uniqueness>" `
    -Location "<region>" `
    -sourceBlobPath "<source data location>" `
    -sinkBlobPath "<sink data location>" `
    -gitUser "<gitUserName>" `
    -gitPassword "<gitAccessKey>" `
    -vstsServer "<vsts server XXX.visualstudio.com>" `
    -vstsAccount "<vsts account server.visualstudio.com/DefaultCollection/XXX>" `
    -projectDir "<gitProjectName>" `
    -subscriptionName "<azure subscription name>" `
    -dsvm "<dsvm>" `
    -pythonPath ".\\sweep_spark.py"
```

## On Batch Windows DSVM Image
### RDP into Node using username `rdpuser`, and provided password. 

### Update Azure PowerShell to >5.X
1. microsoft web platform installer is on the desktop of DSVM, use this to update Powershell

### Install AMLW - MSI must be run from admin cmd. 
1. Windows Key
1. Type `cmd`
1. Right click, select `Run as Admin`
1. Change to D drive with `d:`
1. `cd User\{username}\Downloads
1. AML.msi

### Log into AML Workbench 
1. This is required to create starter folders, remote experiment submission will fail if this is not complete.

