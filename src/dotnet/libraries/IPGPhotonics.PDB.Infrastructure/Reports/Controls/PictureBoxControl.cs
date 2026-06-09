using System;
using System.ComponentModel;
using System.Windows.Forms;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("PictureBoxControl")]
    internal sealed class PictureBoxControl : DialogControl
        {
        [UsedImplicitly][Field(Order=1000501,Converter=typeof(SqlEnumConverter<BorderStyle>))] public BorderStyle BorderStyle { get; }
        [UsedImplicitly][Field(Order=1000502,Converter=typeof(SqlBase64ArrayConverter))] public Byte[] Image { get; }
        [UsedImplicitly][Field(Order=1000503,Converter=typeof(SqlEnumConverter<PictureBoxSizeMode>))][DefaultValue(PictureBoxSizeMode.Normal)] public PictureBoxSizeMode SizeMode { get; } = PictureBoxSizeMode.Normal;
        }
    }
