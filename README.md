# Run Experiment on ADF

This sample shows how to leverage ADF to run an experiment. 

## Create Compute Targets

First, create compute targets for running the parameter sweep: DSVM and optionally, HDInsight Spark Cluster. Select **File**, **Open Command Prompt** and enter following commands to create the compute targets.

Create DSVM. Attach it as compute target, and then prepare it by using:

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


## Run the Model

**Note**: To run sweep_spark.py, you must select DSVM or HDInsight Spark cluster as compute target. The sweep_sklearn.py can run on local Python also.


DSVM run using spark-sklearn

```bash
$ az ml experiment submit -c <dsvm> .\sweep_spark.py
```

HDInsight Spark run using spark-sklearn:

```bash
$ az ml experiment submit -c <myhdi> .\sweep_spark.py
```


## On DSVM
### Update Azure PowerShell to >5.X
1. microsoft web platform installer is on the desktop of DSVM, use this to update Powershell

### Install AMLW - MSI must be run from admin cmd. 
1. Windows Key
1. Type `cmd`
1. Right click, select `Run as Admin`
1. Change to D drive with `d:`
1. `cd User\{username}\Downloads
1. AML.msi

### Log into AMLW

