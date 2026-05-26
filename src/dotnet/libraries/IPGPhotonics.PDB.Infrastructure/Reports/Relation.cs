using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Windows;
using System.Windows.Forms;
using System.Windows.Media;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;

    [FastReportClass("Relation")]
    public class Relation : DataComponentBase
        {
        [UsedImplicitly][Field] public String ChildDataSource { get; }
        [UsedImplicitly][Field] public String ParentDataSource { get; }
        [UsedImplicitly][Field(Converter=typeof(SqlStringConverter))] public IList<String> ParentColumns { get; }
        }
    }