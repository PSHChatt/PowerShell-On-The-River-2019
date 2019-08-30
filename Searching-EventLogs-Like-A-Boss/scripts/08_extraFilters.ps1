## Stem
$start = "2017-07-14T10:41:35.000Z"
$end =  "2017-07-14T11:41:35.999Z"

$xpath = @"
<QueryList>
  <Query Id="0" Path="System">m
    <Select Path="System">*[System[TimeCreated[@SysteTime&gt;='$start' and @SystemTime&lt;='$end']]]</Select>
  </Query>
</QueryList>
"@

## Applicatino - Error - Waring - Critical
$xpath = @"
<QueryList>
  <Query Id="0" Path="Application">
    <Select Path="Application">*[System[(Level=1  or Level=2 or Level=3)]]</Select>
  </Query>
</QueryList>
"@


## All Terminal Services Sessions events
$xpath = @"
<QueryList>
  <Query Id="0" Path="Microsoft-Windows-TerminalServices-LocalSessionManager/Operational">
    <Select Path="Microsoft-Windows-TerminalServices-LocalSessionManager/Operational">*</Select>
  </Query>
</QueryList>
"@
