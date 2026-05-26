using System;
using System.Windows.Forms;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("DateTimePickerControl")]
    public class DateTimePickerControl : DataFilterBaseControl
        {
        [UsedImplicitly][Field] public DateTime Value { get; }
        [UsedImplicitly][Field] public Boolean Checked { get; }
        [UsedImplicitly][Field] public Boolean ShowCheckBox { get; }
        [UsedImplicitly][Field] public Boolean ShowUpDown { get; }
        [UsedImplicitly][Field] public String CustomFormat { get; }
        [UsedImplicitly][Field] public String ValueChangedEvent { get; }
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<LeftRightAlignment>))] public LeftRightAlignment DropDownAlign { get; }
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<DateTimePickerFormat>))] public DateTimePickerFormat Format { get; }
        [UsedImplicitly][Field] public DateTime MaxDate { get; }
        [UsedImplicitly][Field] public DateTime MinDate { get; }
        }
    }