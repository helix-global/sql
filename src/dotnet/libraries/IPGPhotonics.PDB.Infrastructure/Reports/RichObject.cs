using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Windows.Media;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;
using IPGPhotonics.PDB.Infrastructure.Reports;

namespace IPGPhotonics.PDB.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("RichObject")]
    internal sealed class RichObject : TextObjectBase
        {
        [UsedImplicitly][Field] public Int32 ActualTextLength { get; }
        [UsedImplicitly][Field] public String DataColumn { get; }
        [UsedImplicitly][Field] public Boolean OldBreakStyle { get; }
        }
    }
