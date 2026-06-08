using System;
using System.ComponentModel;
using System.Windows.Forms;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("TextBoxControl")]
    internal sealed class TextBoxControl : DataFilterBaseControl
        {
        [UsedImplicitly][Field(Order=1000601)] public Boolean AcceptsReturn { get; }
        [UsedImplicitly][Field(Order=1000602)] public Boolean AcceptsTab { get; }
        [UsedImplicitly][Field(Order=1000605)] public Boolean Multiline { get; }
        [UsedImplicitly][Field(Order=1000606)] public Boolean ReadOnly { get; }
        [UsedImplicitly][Field(Order=1000609)] public Boolean UseSystemPasswordChar { get; }
        [UsedImplicitly][Field(Order=1000610)][DefaultValue(true)] public Boolean WordWrap { get; } = true;
        [UsedImplicitly][Field(Order=1000603,Converter=typeof(SqlEnumConverter<CharacterCasing>))] public CharacterCasing CharacterCasing { get; }
        [UsedImplicitly][Field(Order=1000607,Converter=typeof(SqlEnumConverter<ScrollBars>))] public ScrollBars ScrollBars { get; }
        [UsedImplicitly][Field(Order=1000608,Converter=typeof(SqlEnumConverter<HorizontalAlignment>))] public HorizontalAlignment TextAlign { get; }
        [UsedImplicitly][Field(Order=1000604)][DefaultValue(32767)] public Int32 MaxLength { get; } = 32767;
        }
    }