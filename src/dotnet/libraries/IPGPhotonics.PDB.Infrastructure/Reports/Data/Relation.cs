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
    internal class Relation : DataComponentBase
        {
        [UsedImplicitly][Field] public String ChildDataSource { get; }
        [UsedImplicitly][Field] public String ParentDataSource { get; }
        [UsedImplicitly][Field(Converter=typeof(SqlStringCollectionConverter),ConverterParameter="StringSplitOptions=RemoveEmptyEntries;StringSplitSeparator={\r\n;\r;\n}")] public IList<String> ParentColumns { get; }
        [UsedImplicitly][Field(Converter=typeof(SqlStringCollectionConverter),ConverterParameter="StringSplitOptions=RemoveEmptyEntries;StringSplitSeparator={\r\n;\r;\n}")] public IList<String> ChildColumns { get; }
        }
    }