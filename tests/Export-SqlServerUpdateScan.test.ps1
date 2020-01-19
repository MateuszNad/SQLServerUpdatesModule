
Describe "Eport-SqlServerUpdateScan" {
    It "Test prepare export" {
        Mock Invoke-SqlServerUpdatesScan {
            $ClixmlObject =
            @"
<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">
<Obj RefId="0">
<TN RefId="0">
<T>SqlServerUpdates.Instance</T>
<T>System.Management.Automation.PSCustomObject</T>
<T>System.Object</T>
</TN>
<MS>
<S N="Name">IT-MN-M</S>
<S N="Product">Microsoft SQL Server</S>
<S N="VersionName">SQL Server 2017</S>
<S N="Edition">Developer Edition (64-bit)</S>
<S N="ProductLevel">RTM</S>
<S N="Build">14.0.1000.169</S>
<S N="LatestUpdate">14.0.3257.3</S>
<S N="LatestUpdateLink">&lt; a href="https://support.microsoft.com/en-us/help/4527377/cumulative-update-18-for-sql-server-2017"&gt; CU18&lt; /a&gt; </S>
<Obj N="Updates" RefId="1">
<TN RefId="1">
<T>System.Object[]</T>
<T>System.Array</T>
<T>System.Object</T>
</TN>
<LST>
<Obj RefId="2">
<TN RefId="2">
<T>System.Management.Automation.PSCustomObject</T>
<T>System.Object</T>
</TN>
<MS>
<S N="CumulativeUpdate">&lt; a href="https://support.microsoft.com/en-us/help/4527377/cumulative-update-18-for-sql-server-2017"&gt; CU18&lt; /a&gt; </S>
<S N="ReleaseDate">2019/12/09</S>
<S N="Build">14.0.3257.3</S>
<S N="SupportEnds">2027/10/12</S>
<S N="ServicePack"></S>
</MS>
</Obj>
<Obj RefId="3">
<TNRef RefId="2" />
<MS>
<S N="CumulativeUpdate">&lt; a href="https://support.microsoft.com/en-us/help/4515579/cumulative-update-17-for-sql-server-2017"&gt; CU17&lt; /a&gt; </S>
<S N="ReleaseDate">2019/10/08</S>
<S N="Build">14.0.3238.1</S>
<S N="SupportEnds">2027/10/12</S>
<S N="ServicePack"></S>
</MS>
</Obj>
<Obj RefId="4">
<TNRef RefId="2" />
<MS>
<S N="CumulativeUpdate">&lt; a href="https://support.microsoft.com/en-us/help/4508218/cumulative-update-16-for-sql-server-2017"&gt; CU16&lt; /a&gt; </S>
<S N="ReleaseDate">2019/08/01</S>
<S N="Build">14.0.3223.3</S>
<S N="SupportEnds">2027/10/12</S>
<S N="ServicePack"></S>
</MS>
</Obj>
<Obj RefId="5">
<TNRef RefId="2" />
<MS>
<S N="CumulativeUpdate">&lt; a href="https://support.microsoft.com/en-us/help/4505225/security-update-for-sql-server-2017-cu15-gdr-july-9-2019"&gt; Security update&lt; /a&gt; </S>
<S N="ReleaseDate">2019/07/09</S>
<S N="Build">14.0.3192.2</S>
<S N="SupportEnds">2027/10/12</S>
<S N="ServicePack"></S>
</MS>
</Obj>
<Obj RefId="6">
<TNRef RefId="2" />
<MS>
<S N="CumulativeUpdate">&lt; a href="https://support.microsoft.com/en-us/help/4506633/on-demand-hotfix-update-package-for-sql-server-2017-cu15"&gt; Hotfix&lt; /a&gt; </S>
<S N="ReleaseDate">2019/06/21</S>
<S N="Build">14.0.3164.1</S>
<S N="SupportEnds">2027/10/12</S>
<S N="ServicePack"></S>
</MS>
</Obj>
<Obj RefId="7">
<TNRef RefId="2" />
<MS>
<S N="CumulativeUpdate">&lt; a href="https://support.microsoft.com/en-us/help/4498951/cumulative-update-15-for-sql-server-2017"&gt; CU15&lt; /a&gt; </S>
<S N="ReleaseDate">2019/05/24</S>
<S N="Build">14.0.3162.1</S>
<S N="SupportEnds">2027/10/12</S>
<S N="ServicePack"></S>
</MS>
</Obj>
<Obj RefId="8">
<TNRef RefId="2" />
<MS>
<S N="CumulativeUpdate">&lt; a href="https://support.microsoft.com/en-us/help/4484710/cumulative-update-14-for-sql-server-2017"&gt; CU14&lt; /a&gt; </S>
<S N="ReleaseDate">2019/03/25</S>
<S N="Build">14.0.3076.1</S>
<S N="SupportEnds">2027/10/12</S>
<S N="ServicePack"></S>
</MS>
</Obj>
<Obj RefId="9">
<TNRef RefId="2" />
<MS>
<S N="CumulativeUpdate">&lt; a href="https://support.microsoft.com/en-us/help/4483666/on-demand-hotfix-update-package-for-sql-server-2017-cu13"&gt; Hotfix&lt; /a&gt; </S>
<S N="ReleaseDate">2019/01/07</S>
<S N="Build">14.0.3049.1</S>
<S N="SupportEnds">2027/10/12</S>
<S N="ServicePack"></S>
</MS>
</Obj>
<Obj RefId="10">
<TNRef RefId="2" />
<MS>
<S N="CumulativeUpdate">&lt; a href="https://support.microsoft.com/en-us/help/4466404/cumulative-update-13-for-sql-server-2017"&gt; CU13&lt; /a&gt; </S>
<S N="ReleaseDate">2018/12/18</S>
<S N="Build">14.0.3048.4</S>
<S N="SupportEnds">2027/10/12</S>
<S N="ServicePack"></S>
</MS>
</Obj>
<Obj RefId="11">
<TNRef RefId="2" />
<MS>
<S N="CumulativeUpdate">&lt; a href="https://support.microsoft.com/en-us/help/4464082/cumulative-update-12-for-sql-server-2017"&gt; CU12&lt; /a&gt; </S>
<S N="ReleaseDate">2018/10/24</S>
<S N="Build">14.0.3045.24</S>
<S N="SupportEnds">2027/10/12</S>
<S N="ServicePack"></S>
</MS>
</Obj>
<Obj RefId="12">
<TNRef RefId="2" />
<MS>
<S N="CumulativeUpdate">&lt; a href="https://support.microsoft.com/en-us/help/4462262/cumulative-update-11-for-sql-server-2017"&gt; CU11&lt; /a&gt; </S>
<S N="ReleaseDate">2018/09/20</S>
<S N="Build">14.0.3038.14</S>
<S N="SupportEnds">2027/10/12</S>
<S N="ServicePack"></S>
</MS>
</Obj>
<Obj RefId="13">
<TNRef RefId="2" />
<MS>
<S N="CumulativeUpdate">&lt; a href="https://support.microsoft.com/en-us/help/4342123/cumulative-update-10-for-sql-server-2017"&gt; CU10&lt; /a&gt; </S>
<S N="ReleaseDate">2018/08/27</S>
<S N="Build">14.0.3037.1</S>
<S N="SupportEnds">2027/10/12</S>
<S N="ServicePack"></S>
</MS>
</Obj>
<Obj RefId="14">
<TNRef RefId="2" />
<MS>
<S N="CumulativeUpdate">&lt; a href="https://support.microsoft.com/en-us/help/4293805/security-update-for-remote-code-execution-vulnerability-in-sql-server"&gt; GDR2&lt; /a&gt; (security patch to CU9)</S>
<S N="ReleaseDate">2018/08/14</S>
<S N="Build">14.0.3035.2</S>
<S N="SupportEnds">2027/10/12</S>
<S N="ServicePack"></S>
</MS>
</Obj>
<Obj RefId="15">
<TNRef RefId="2" />
<MS>
<S N="CumulativeUpdate">&lt; a href="https://support.microsoft.com/en-us/help/4341265/cumulative-update-9-for-sql-server-2017"&gt; CU9&lt; /a&gt; </S>
<S N="ReleaseDate">2018/07/18</S>
<S N="Build">14.0.3030.27</S>
<S N="SupportEnds">2027/10/12</S>
<S N="ServicePack"></S>
</MS>
</Obj>
<Obj RefId="16">
<TNRef RefId="2" />
<MS>
<S N="CumulativeUpdate">&lt; a href="https://support.microsoft.com/en-us/help/4338363/cumulative-update-8-for-sql-server-2017"&gt; CU8&lt; /a&gt; </S>
<S N="ReleaseDate">2018/06/20</S>
<S N="Build">14.0.3029.16</S>
<S N="SupportEnds">2027/10/12</S>
<S N="ServicePack"></S>
</MS>
</Obj>
<Obj RefId="17">
<TNRef RefId="2" />
<MS>
<S N="CumulativeUpdate">&lt; a href="https://support.microsoft.com/en-us/help/4229789/cumulative-update-7-for-sql-server-2017"&gt; CU7&lt; /a&gt; </S>
<S N="ReleaseDate">2018/05/24</S>
<S N="Build">14.0.3026.27</S>
<S N="SupportEnds">2027/10/12</S>
<S N="ServicePack"></S>
</MS>
</Obj>
<Obj RefId="18">
<TNRef RefId="2" />
<MS>
<S N="CumulativeUpdate">&lt; a href="https://support.microsoft.com/en-us/help/4101464/cumulative-update-6-for-sql-server-2017"&gt; CU6&lt; /a&gt; </S>
<S N="ReleaseDate">2018/04/19</S>
<S N="Build">14.0.3025.34</S>
<S N="SupportEnds">2027/10/12</S>
<S N="ServicePack"></S>
</MS>
</Obj>
<Obj RefId="19">
<TNRef RefId="2" />
<MS>
<S N="CumulativeUpdate">&lt; a href="https://support.microsoft.com/en-us/help/4092643/cumulative-update-5-for-sql-server-2017"&gt; CU5&lt; /a&gt; </S>
<S N="ReleaseDate">2018/03/20</S>
<S N="Build">14.0.3023.8</S>
<S N="SupportEnds">2027/10/12</S>
<S N="ServicePack"></S>
</MS>
</Obj>
<Obj RefId="20">
<TNRef RefId="2" />
<MS>
<S N="CumulativeUpdate">&lt; a href="https://support.microsoft.com/en-us/help/4056498/cumulative-update-4-for-sql-server-2017"&gt; CU4&lt; /a&gt; </S>
<S N="ReleaseDate">2018/02/21</S>
<S N="Build">14.0.3022.28</S>
<S N="SupportEnds">2027/10/12</S>
<S N="ServicePack"></S>
</MS>
</Obj>
<Obj RefId="21">
<TNRef RefId="2" />
<MS>
<S N="CumulativeUpdate">&lt; a href="https://support.microsoft.com/en-us/help/4052987/cumulative-update-3-for-sql-server-2017"&gt; CU3&lt; /a&gt; </S>
<S N="ReleaseDate">2018/01/04</S>
<S N="Build">14.0.3015.40</S>
<S N="SupportEnds">2027/10/12</S>
<S N="ServicePack"></S>
</MS>
</Obj>
<Obj RefId="22">
<TNRef RefId="2" />
<MS>
<S N="CumulativeUpdate">&lt; a href="https://support.microsoft.com/en-us/help/4052574/cumulative-update-2-for-sql-server-2017"&gt; CU2&lt; /a&gt; ??(note &lt; a href="http://tracyboggiano.com/archive/2017/12/sql-server-2017-cu2-bug/"&gt; bug&lt; /a&gt; )</S>
<S N="ReleaseDate">2017/11/29</S>
<S N="Build">14.0.3008.27</S>
<S N="SupportEnds">2027/10/12</S>
<S N="ServicePack"></S>
</MS>
</Obj>
<Obj RefId="23">
<TNRef RefId="2" />
<MS>
<S N="CumulativeUpdate">&lt; a href="https://support.microsoft.com/en-us/help/4038634/cumulative-update-1-for-sql-server-2017"&gt; CU1&lt; /a&gt; </S>
<S N="ReleaseDate">2017/10/25</S>
<S N="Build">14.0.3006.16</S>
<S N="SupportEnds">2027/10/12</S>
<S N="ServicePack"></S>
</MS>
</Obj>
<Obj RefId="24">
<TNRef RefId="2" />
<MS>
<S N="CumulativeUpdate">&lt; a href="https://support.microsoft.com/en-us/help/4293803/description-of-the-security-update-for-the-remote-code-execution-vulne"&gt; GDR&lt; /a&gt; (security patch to RTM)</S>
<S N="ReleaseDate">2018/08/14</S>
<S N="Build">14.0.2000.63</S>
<S N="SupportEnds">2027/10/12</S>
<S N="ServicePack"></S>
</MS>
</Obj>
</LST>
</Obj>
<B N="ToUpdate">true</B>
</MS>
</Obj>
</Objs>
"@
            Set-Content -Value $ClixmlObject -Path (New-TemporaryFile -OutVariable TempFile)
            Import-Clixml -Path $TempFile.FullName | Export-SqlServerUpdatesScan
        }
        Mock Out-File {
            Write-Output $file
        }
        Invoke-SqlServerUpdatesScan | Export-SqlServerUpdatesScan | Should Not Be $null
    }
}
