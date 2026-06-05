using System;
using System.Windows.Forms;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("DateTimePickerControl")]
    internal sealed class DateTimePickerControl : DataFilterBaseControl
        {
        [UsedImplicitly][Field(Order=1000609)] public DateTime Value { get; }
        [UsedImplicitly][Field(Order=1000601)] public Boolean Checked { get; }
        [UsedImplicitly][Field(Order=1000607)] public Boolean ShowCheckBox { get; }
        [UsedImplicitly][Field(Order=1000608)] public Boolean ShowUpDown { get; }
        [UsedImplicitly][Field(Order=1000602)] public String CustomFormat { get; }
        [UsedImplicitly][Field(Order=1000610)] public String ValueChangedEvent { get; }
        [UsedImplicitly][Field(Order=1000603,Converter=typeof(SqlEnumConverter<LeftRightAlignment>))] public LeftRightAlignment DropDownAlign { get; }
        [UsedImplicitly][Field(Order=1000604,Converter=typeof(SqlEnumConverter<DateTimePickerFormat>))] public DateTimePickerFormat Format { get; }
        [UsedImplicitly][Field(Order=1000605)] public DateTime MaxDate { get; }
        [UsedImplicitly][Field(Order=1000606)] public DateTime MinDate { get; }
        }
    }