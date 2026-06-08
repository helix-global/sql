using System;
using System.Windows.Forms;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("PictureBoxControl")]
    internal sealed class PictureBoxControl : DialogControl
        {
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<BorderStyle>))] public BorderStyle BorderStyle { get; }
        [UsedImplicitly][Field(Converter=typeof(SqlBase64ArrayConverter))] public Byte[] Image { get; }
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<PictureBoxSizeMode>))] public PictureBoxSizeMode SizeMode { get; } = PictureBoxSizeMode.Normal;
        }
    }
