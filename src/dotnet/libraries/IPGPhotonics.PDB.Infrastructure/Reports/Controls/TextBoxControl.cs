using System;
using System.Windows.Forms;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("TextBoxControl")]
    internal sealed class TextBoxControl : DataFilterBaseControl
        {
        protected internal override String ClassName { get { return "TextBoxControl"; }}
        [UsedImplicitly][Field] public Boolean AcceptsReturn { get; }
        [UsedImplicitly][Field] public Boolean AcceptsTab { get; }
        [UsedImplicitly][Field] public Boolean Multiline { get; }
        [UsedImplicitly][Field] public Boolean ReadOnly { get; }
        [UsedImplicitly][Field] public Boolean UseSystemPasswordChar { get; }
        [UsedImplicitly][Field] public Boolean WordWrap { get; } = true;
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<CharacterCasing>))] public CharacterCasing CharacterCasing { get; }
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<ScrollBars>))] public ScrollBars ScrollBars { get; }
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<HorizontalAlignment>))] public HorizontalAlignment TextAlign { get; }
        [UsedImplicitly][Field] public Int32 MaxLength { get; } = 32767;
        }
    }