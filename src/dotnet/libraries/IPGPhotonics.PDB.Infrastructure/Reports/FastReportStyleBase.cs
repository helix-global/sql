using System;
using System.Drawing;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;
using System.ComponentModel;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class FastReportStyleBase : FastReportObject
        {
        [UsedImplicitly][Field(Order=1000105)] public virtual Boolean ApplyBorder { get; }
        [UsedImplicitly][Field(Order=1000106)][DefaultValue(true)] public virtual Boolean ApplyFill { get; } = true;
        [UsedImplicitly][Field(Order=1000108)] public virtual Boolean ApplyFont { get; }
        [UsedImplicitly][Field(Order=1000107)][DefaultValue(true)] public Boolean ApplyTextFill { get; } = true;
        [UsedImplicitly][Field(Order=1000104)] public String Font { get; }
        [UsedImplicitly][Field(Order=1000102)][DefaultValue(typeof(FastReportSolidFill),"Color=Transparent")] public FillBase Fill { get; } = new FastReportSolidFill(Color.Transparent);
        [UsedImplicitly][Field(Order=1000103)][DefaultValue(typeof(FastReportSolidFill),"Color=Black")] public FillBase TextFill { get; } = new FastReportSolidFill(Color.Black);
        [UsedImplicitly][Field(Order=1000101)] public Border Border { get; } = new Border();
        }
    }