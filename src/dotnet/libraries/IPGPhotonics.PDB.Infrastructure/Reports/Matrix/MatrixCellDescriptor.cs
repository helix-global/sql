using System.ComponentModel;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("Cell")]
    internal sealed class MatrixCellDescriptor : MatrixDescriptor
        {
        [UsedImplicitly][Field(Order=1000301)][DefaultValue(MatrixAggregateFunction.Sum)] public MatrixAggregateFunction Function { get; } = MatrixAggregateFunction.Sum;
        [UsedImplicitly][Field(Order=1000302)] public MatrixPercent Percent { get; }
        }
    }