using System;
using System.ComponentModel;
using System.Drawing;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("LabelControl")]
    internal sealed class LabelControl : DialogControl
        {
        [UsedImplicitly][Field(Order=1000501)][DefaultValue(true)] public Boolean AutoSize { get; } = true;
        [UsedImplicitly][Field(Order=1000502,Converter=typeof(SqlEnumConverter<ContentAlignment>))] public ContentAlignment TextAlign { get; }
        }
    }
