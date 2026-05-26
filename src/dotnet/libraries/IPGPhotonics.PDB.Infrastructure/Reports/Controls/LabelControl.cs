using System;
using System.Drawing;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("LabelControl")]
    internal class LabelControl : DialogControl
        {
        [UsedImplicitly][Field] public Boolean AutoSize { get; } = true;
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<ContentAlignment>))] public ContentAlignment TextAlign { get; }
        }
    }
