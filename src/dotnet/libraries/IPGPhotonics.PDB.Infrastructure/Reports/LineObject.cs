using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Windows.Forms;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("LineObject")]
    internal sealed class LineObject : ReportComponentBase
        {
        [UsedImplicitly][Field] public Boolean Diagonal { get; }
        }
    }
