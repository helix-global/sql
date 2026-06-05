using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("TableObject")]
    internal sealed class TableObject : TableBase
        {
        protected internal override String ClassName { get { return "TableObject"; }}
        [UsedImplicitly][Field] public Boolean ManualBuildAutoSpans { get; } = true;
        [UsedImplicitly][Field] public String ManualBuildEvent { get; }
        }
    }
