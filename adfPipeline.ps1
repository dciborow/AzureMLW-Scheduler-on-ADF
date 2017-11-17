# Set variables with your own values
$resourceGroupName = ""
$dataFactoryName = "" # must be globally unquie
$dataFactoryRegion = "" 
$storageAccountName = ""
$storageAccountKey = ""
$sourceBlobPath = "" # example: adftutorial/input
$sinkBlobPath = "" # example: adftutorial/output
$pipelineName = "MLPipeline"

# Create a resource group
#New-AzureRmResourceGroup -Name $resourceGroupName -Location $dataFactoryRegion

# Create a data factory
$df = Set-AzureRmDataFactoryV2 -ResourceGroupName $resourceGroupName -Location $dataFactoryRegion -Name $dataFactoryName 

# Create an Azure Storage linked service Rin the data factory

## JSON definition of the linked service. 
$storageLinkedServiceDefinition = @"
{
    "name": "AzureStorageLinkedService",
    "properties": {
        "type": "AzureStorage",
        "typeProperties": {
            "connectionString": {
                "value": "DefaultEndpointsProtocol=https;AccountName=$storageAccountName;AccountKey=$storageAccountKey",
                "type": "SecureString"
            }
        }
    }
}
"@

## IMPORTANT: stores the JSON definition in a file that will be used by the Set-AzureRmDataFactoryV2LinkedService command. 
$storageLinkedServiceDefinition | Out-File c:\StorageLinkedService.json

## Creates a linked service in the data factory
Set-AzureRmDataFactoryV2LinkedService -DataFactoryName $dataFactoryName -ResourceGroupName $resourceGroupName -Name "AzureStorageLinkedService" -File c:\StorageLinkedService.json

# Create an Azure Blob dataset in the data factory

## JSON definition of the dataset
$datasetDefiniton = @"
{
    "name": "BlobDataset",
    "properties": {
        "type": "AzureBlob",
        "typeProperties": {
            "folderPath": {
                "value": "@{dataset().path}",
                "type": "Expression"
            }
        },
        "linkedServiceName": {
            "referenceName": "AzureStorageLinkedService",
            "type": "LinkedServiceReference"
        },
        "parameters": {
            "path": {
                "type": "String"
            }
        }
    }
}
"@

## IMPORTANT: store the JSON definition in a file that will be used by the Set-AzureRmDataFactoryV2Dataset command. 
$datasetDefiniton | Out-File c:\BlobDataset.json

## Create a dataset in the data factory
Set-AzureRmDataFactoryV2Dataset -DataFactoryName $dataFactoryName -ResourceGroupName $resourceGroupName -Name "BlobDataset" -File "c:\BlobDataset.json"

#Create Azure Batch linked Service
$batchDefinition = @"
{
    "name": "AzureBatchLinkedService",
    "properties": {
        "type": "AzureBatch",
        "typeProperties": {
            "accountName": "",
            "accessKey": {
                "type": "SecureString",
                "value": ""
            },
            "batchUri": "https://..batch.azure.com",
            "poolName": "",
            "linkedServiceName": {
                "referenceName": "AzureStorageLinkedService",
                "type": "LinkedServiceReference"
            }
        }
    }
}
"@
## IMPORTANT: store the JSON definition in a file that will be used by the Set-AzureRmDataFactoryV2Dataset command. 
$batchDefinition | Out-File c:\BatchCompute.json

##TODO
## Create a dataset in the data factory
Set-AzureRmDataFactoryV2LinkedService -DataFactoryName $dataFactoryName -ResourceGroupName $resourceGroupName -Name "BatchCompute" -File "c:\BatchCompute.json"

# Create a pipeline in the data factory

## JSON definition of the pipeline
$pipelineDefinition = @"
{
    "name": "$pipelineName",
    "properties": {
        "activities": [
            {
              "type": "Custom",
              "name": "RunPC",
              "linkedServiceName": {
                "referenceName": "BatchCompute",
                "type": "LinkedServiceReference"
              },
              "typeProperties": {
                "command": "cmd /c git clone https://dciborow:@.visualstudio.com/DefaultCollection//_git/blads_dcib_cinderella_spark_h2o && powershell.exe -file .\\blads_dcib_cinderella_spark_h2o\\batchTask.ps1"
              },
              "resourceLinkedService": {
                "referenceName": "AzureStorageLinkedService",
                "type": "LinkedServiceReference"
              }
            }
        ]
    }
}
"@

## IMPORTANT: store the JSON definition in a file that will be used by the Set-AzureRmDataFactoryV2Pipeline command. 
$pipelineDefinition | Out-File c:\CopyPipeline.json

## Create a pipeline in the data factory
Set-AzureRmDataFactoryV2Pipeline -DataFactoryName $dataFactoryName -ResourceGroupName $resourceGroupName -Name $pipelineName -File "c:\CopyPipeline.json"

# Create a pipeline run 

## JSON definition for pipeline parameters
$pipelineParameters = @"
{
    "inputPath": "$sourceBlobPath",
    "outputPath": "$sinkBlobPath"
}
"@

## IMPORTANT: store the JSON definition in a file that will be used by the Invoke-AzureRmDataFactoryV2Pipeline command. 
$pipelineParameters | Out-File c:\PipelineParameters.json

# Create a pipeline run by using parameters
$runId = Invoke-AzureRmDataFactoryV2Pipeline -DataFactoryName $dataFactoryName -ResourceGroupName $resourceGroupName -PipelineName $pipelineName -ParameterFile c:\PipelineParameters.json

# Check the pipeline run status until it finishes the copy operation
while ($True) {
    $result = Get-AzureRmDataFactoryV2ActivityRun -DataFactoryName $dataFactoryName -ResourceGroupName $resourceGroupName -PipelineRunId $runId -RunStartedAfter (Get-Date).AddMinutes(-30) -RunStartedBefore (Get-Date).AddMinutes(30)

    if (($result | Where-Object { $_.Status -eq "InProgress" } | Measure-Object).count -ne 0) {
        Write-Host "Pipeline run status: In Progress" -foregroundcolor "Yellow"
        Start-Sleep -Seconds 30
    }
    else {
        Write-Host "Pipeline '$pipelineName' run finished. Result:" -foregroundcolor "Yellow"
        $result
        break
    }
}

# Get the activity run details 
    $result = Get-AzureRmDataFactoryV2ActivityRun -DataFactoryName $dataFactoryName -ResourceGroupName $resourceGroupName `
        -PipelineRunId $runId `
        -RunStartedAfter (Get-Date).AddMinutes(-10) `
        -RunStartedBefore (Get-Date).AddMinutes(10) `
        -ErrorAction Stop

    $result

    if ($result.Status -eq "Succeeded") {`
        $result.Output -join "`r`n"`
    }`
    else {`
        $result.Error -join "`r`n"`
    }

# To remove the data factory from the resource gorup
# Remove-AzureRmDataFactoryV2 -Name $dataFactoryName -ResourceGroupName $resourceGroupName
# 
# To remove the whole resource group
# Remove-AzureRmResourceGroup  -Name $resourceGroupName
