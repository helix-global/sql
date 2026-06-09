using System;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("CheckedTreeViewControl")]
    internal sealed class CheckedTreeViewControl : BindableDialogControl
        {
        [UsedImplicitly][Field(Order=1000601)] public Boolean AllowRecursiveNodeChecking { get; }
        }
    }
