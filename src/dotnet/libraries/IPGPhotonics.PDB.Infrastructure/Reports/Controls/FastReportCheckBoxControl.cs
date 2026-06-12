using System;
using System.ComponentModel;
using System.Drawing;
using System.Windows.Forms;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;

    [FastReportClass("CheckBoxControl")]
    internal sealed class FastReportCheckBoxControl : FastReportButtonBaseControl
        {
        [UsedImplicitly][Field(Order=1000701,Converter=typeof(SqlEnumConverter<Appearance>))] public Appearance Appearance { get; }
        [UsedImplicitly][Field(Order=1000702,Converter=typeof(SqlEnumConverter<ContentAlignment>))][DefaultValue(ContentAlignment.MiddleLeft)] public ContentAlignment CheckAlign { get; } = ContentAlignment.MiddleLeft;
        [UsedImplicitly][Field(Order=1000704,Converter=typeof(SqlEnumConverter<CheckState>))] public CheckState CheckState { get; }
        [UsedImplicitly][Field(Order=1000703)] public Boolean Checked { get; }
        [UsedImplicitly][Field(Order=1000705)] public Boolean ThreeState { get; }
        [UsedImplicitly][Field(Order=1000706)] public String CheckedChangedEvent { get; }
        }
    }