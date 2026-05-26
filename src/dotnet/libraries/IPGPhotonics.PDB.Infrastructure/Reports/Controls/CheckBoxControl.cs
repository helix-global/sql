using System;
using System.Drawing;
using System.Windows.Forms;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;

    [FastReportClass("CheckBoxControl")]
    public class CheckBoxControl : ButtonBaseControl
        {
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<Appearance>))] public Appearance Appearance { get; }
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<ContentAlignment>))] public ContentAlignment CheckAlign { get; } = ContentAlignment.MiddleLeft;
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<CheckState>))] public CheckState CheckState { get; }
        [UsedImplicitly][Field] public Boolean Checked { get; }
        [UsedImplicitly][Field] public Boolean ThreeState { get; }
        [UsedImplicitly][Field] public String CheckedChangedEvent { get; }
        }
    }