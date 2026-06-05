using System;
using System.ComponentModel;
using System.Drawing;
using System.Windows.Forms;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class ButtonBaseControl : DataFilterBaseControl
        {
        [UsedImplicitly][Field(Order=1000602,Converter=typeof(SqlBase64ArrayConverter))] public Byte[] Image { get; }
        [UsedImplicitly][Field(Order=1000601)] public Boolean AutoSize { get; }
        [UsedImplicitly][Field(Order=1000604,Converter=typeof(SqlEnumConverter<ContentAlignment>))][DefaultValue(ContentAlignment.MiddleLeft)] public ContentAlignment TextAlign { get; } = ContentAlignment.MiddleLeft;
        [UsedImplicitly][Field(Order=1000605,Converter=typeof(SqlEnumConverter<TextImageRelation>))] public TextImageRelation TextImageRelation { get; }
        [UsedImplicitly][Field(Order=1000603,Converter=typeof(SqlEnumConverter<ContentAlignment>))][DefaultValue(ContentAlignment.MiddleCenter)] public ContentAlignment ImageAlign { get; } = ContentAlignment.MiddleCenter;
        }
    }