using System;
using System.Drawing;
using System.Windows.Forms;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    public abstract class ButtonBaseControl : DataFilterBaseControl
        {
        [UsedImplicitly][Field(Converter=typeof(SqlArrayConverter))] public Byte[] Image { get; }
        [UsedImplicitly][Field] public Boolean AutoSize { get; }
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<ContentAlignment>))] public ContentAlignment TextAlign { get; } = ContentAlignment.MiddleLeft;
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<TextImageRelation>))] public TextImageRelation TextImageRelation { get; }
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<ContentAlignment>))] public ContentAlignment ImageAlign { get; } = ContentAlignment.MiddleCenter;
        }
    }