function Format-ImportExcelDate {
    <#
.SYNOPSIS
 Correct dates when using Import-Excel
.DESCRIPTION
 Corects common Excel date/time formats when running Dfinke's Import-Excel module
.PARAMETER CellData
 Data to be converted to datetime format
.PARAMETER DateOnNull
 Static Date and Time returned when CellData is not provided or missing
.EXAMPLE
$ImportedExcel = Import-Excel -Path $Path -WorksheetName $WrkShtName |
    foreach {
        $CellObject = $_
        $CellObject.DateColumn = $CellObject.DateColumn |
            Format-ImportExcelDate -DateOnNull ((get-date).Date)
        $CellObject
    }

    Command shows how import an Excel worksheet
     and format cell values in the column "DateColumn"
    to a .NET datetime value.
    The current date/time is
    returned when an imported cell is empty
.Notes
 Name: Format-ImportExcelDate
 Author: Mark Curry
 Keywords: Powershell,Excel,Date,Time
.Link
 https://github.com/i-ScriptALot
 .Link
 https://github.com/dfinke/ImportExcel
.Inputs
Object
.Outputs
System.DateTime
#>
    # Requires -Version 2.0
    [CmdletBinding()]
    Param
    (
        [Parameter(ValueFromPipeline = $True, Position = 0)]
        [System.Object[]]$CellData,
        [Parameter(Position = 1)]
        [DateTime]$DateOnNull
    )

    PROCESS {
        Write-Debug -Message "Begin Imported Date Update, Cell Data Count is $($CellData.count)"
        Write-Debug -Message "DateOnNull is $($DateOnNull)"


        foreach ($Value in $CellData) {
            $ValueType = ($Value).gettype().name
            Write-Debug "Processing $Value with type $ValueType"
            switch ($true) {
                (-not $Value -and $DateOnNull) {
                    $DateValue = $DateOnNull
                    break
                }
                (-not $Value -and -not $DateOnNull) {
                    $DateValue = ''
                    break
                }
                ($ValueType -eq 'Double') {
                    $DateValue = [datetime]::FromOADate($Value)
                    break
                }
                ($ValueType -eq 'int32' -or $ValueType -eq 'int') {
                    $DateValue = [datetime]::FromOADate($Value)
                    break
                }
                ($ValueType -eq 'DateTime') {
                    $DateValue = $Value
                    break
                }
                Default {
                    $DateValue = $Value
                }
            }
            Write-Debug -message "Writing $DateValue to pipeline"
            $DateValue
        } # End foreach
    } # End process block
} #End function

