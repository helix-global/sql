using System;
using System.ComponentModel;
using System.Drawing;
using System.Windows.Forms;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("MonthCalendarControl")]
    internal sealed class FastReportMonthCalendarControl : FastReportDataFilterBaseControl
        {
        [UsedImplicitly][Field(Order=1000606)][DefaultValue(true)] public Boolean ShowToday { get; } = true;
        [UsedImplicitly][Field(Order=1000607)][DefaultValue(true)] public Boolean ShowTodayCircle { get; } = true;
        [UsedImplicitly][Field(Order=1000608)] public Boolean ShowWeekNumbers { get; }
        [UsedImplicitly][Field(Order=1000610)] public String DateChangedEvent { get; }
        [UsedImplicitly][Field(Order=1000602,Converter=typeof(SqlEnumConverter<Day>))] public Day FirstDayOfWeek { get; }
        [UsedImplicitly][Field(Order=1000603)] public DateTime MaxDate { get; }
        [UsedImplicitly][Field(Order=1000605)] public DateTime MinDate { get; }
        [UsedImplicitly][Field(Order=1000609)] public DateTime TodayDate { get; }
        [UsedImplicitly][Field(Order=1000604)][DefaultValue(7)] public Int32 MaxSelectionCount { get; } = 7;
        [UsedImplicitly][Field(Order=1000601)] public Size CalendarDimensions { get; }
        }
    }