using System;
using System.ComponentModel;
using System.Drawing;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("RadioButtonControl")]
    public class RadioButtonControl : ButtonBaseControl
        {
        [UsedImplicitly][Field][TypeConverter(typeof(SqlEnumConverter<ContentAlignment>))] public ContentAlignment CheckAlign { get; }
        [UsedImplicitly][Field] public Boolean Checked { get; }
        [UsedImplicitly][Field] public String CheckedChangedEvent { get; }
        }
    }