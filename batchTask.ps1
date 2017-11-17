$secpasswd = ConvertTo-SecureString "B1g-D6taRocks" -AsPlainText -Force
$secureCredential = New-Object System.Management.Automation.PSCredential ("53a17123-109f-4cd9-bb39-5a0bac92781d", $secpasswd)


$tenantId = "72f988bf-86f1-41af-91ab-2d7cd011db47"
Add-AzureRmAccount -ServicePrincipal -Tenant $tenantId -Credential $secureCredential

$context = Get-AzureRmBatchAccountKeys -ResourceGroupName alicebobandnick -AccountName alicebatch
$userIdentity = New-Object Microsoft.Azure.Commands.Batch.Models.PSUserIdentity "rdpuser"
$taskid = "azmltask{0:G}" -f [int][double]::Parse((Get-Date -UFormat %s))
Get-AzureBatchJob -Id "adfv2-alicewindows2" -BatchContext $Context | New-AzureBatchTask -Id $taskid -CommandLine "cmd /c set PATH=%LOCALAPPDATA%\amlworkbench\Python;%LOCALAPPDATA%\amlworkbench\Python\Scripts;%PATH% && git clone https://dciborow:@.visualstudio.com/DefaultCollection//_git/blads_dcib_cinderella_spark_h2o && az login --service-principal -u Q$@!#!$@-$@#$-%W$@$-#%#@-!@$%!#@%$@ --password 12532143 --tenant 32453452-2344-3455-2334-342523452345 && cd .\blads_dcib_cinderella_spark_h2o && az ml experiment submit -c dsvm .\spark-recommender\als_train_recommend.py" -UserIdentity "rdpuser" -BatchContext $Context
