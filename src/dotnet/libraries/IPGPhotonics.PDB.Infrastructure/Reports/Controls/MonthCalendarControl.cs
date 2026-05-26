using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Windows.Forms;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("MonthCalendarControl")]
    internal sealed class MonthCalendarControl : DataFilterBaseControl
        {
        [UsedImplicitly][Field] public Boolean ShowToday { get; } = true;
        [UsedImplicitly][Field] public Boolean ShowTodayCircle { get; } = true;
        [UsedImplicitly][Field] public Boolean ShowWeekNumbers { get; }
        [UsedImplicitly][Field] public String DateChangedEvent { get; }
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<Day>))] public Day FirstDayOfWeek { get; }
        [UsedImplicitly][Field] public DateTime MaxDate { get; }
        [UsedImplicitly][Field] public DateTime MinDate { get; }
        [UsedImplicitly][Field] public Int32 MaxSelectionCount { get; } = 7;
        }
    }