using System;
using System.Drawing;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    public sealed class BorderLine : FastReportObject
        {
        [UsedImplicitly][Field(Converter=typeof(SqlColorConverter))] public Color Color { get;set; }
        [UsedImplicitly][Field] public LineStyle Style { get;set; }
        [UsedImplicitly][Field] public Single Width { get;set; } = 1f;
        }
    }