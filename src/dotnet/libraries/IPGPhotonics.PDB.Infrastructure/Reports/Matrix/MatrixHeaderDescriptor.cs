using System;
using System.ComponentModel;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("Header")]
    internal sealed class MatrixHeaderDescriptor : MatrixDescriptor
        {
        [UsedImplicitly][Field(Order=1000304)] public Boolean PageBreak { get; }
        [UsedImplicitly][Field(Order=1000305)] public Boolean SuppressTotals { get; }
        [UsedImplicitly][Field(Order=1000302)][DefaultValue(true)] public Boolean Totals { get; } = true;
        [UsedImplicitly][Field(Order=1000303)] public Boolean TotalsFirst { get; }
        [UsedImplicitly][Field(Order=1000301)][DefaultValue(SortOrder.Ascending)] public SortOrder Sort { get; } = SortOrder.Ascending;
        }
    }