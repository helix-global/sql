using System;
using System.Collections.Generic;
using System.ComponentModel;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("Cell")]
    internal sealed class MatrixCellDescriptor : MatrixDescriptor
        {
        [UsedImplicitly][Field] public MatrixAggregateFunction Function { get; }
        [UsedImplicitly][Field] public MatrixPercent Percent { get; }
        }
    }