using System;
using System.Collections.Generic;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("Relation")]
    internal sealed class FastReportRelation : FastReportDataComponentBase
        {
        [UsedImplicitly][Field(Order=1000302)] public String ChildDataSource { get; }
        [UsedImplicitly][Field(Order=1000301)] public String ParentDataSource { get; }
        [UsedImplicitly][Field(Order=1000303,Converter=typeof(SqlStringCollectionConverter),ConverterParameter="StringSplitOptions=RemoveEmptyEntries;StringSplitSeparator={\r\n;\r;\n}")] public IList<String> ParentColumns { get; }
        [UsedImplicitly][Field(Order=1000304,Converter=typeof(SqlStringCollectionConverter),ConverterParameter="StringSplitOptions=RemoveEmptyEntries;StringSplitSeparator={\r\n;\r;\n}")] public IList<String> ChildColumns { get; }
        [UsedImplicitly][Field(Order=1000305)][DefaultValue(false)] public override Boolean Enabled { get; }

        #region M:Serialize(IFastReportSerializer,String,Object)
        public override void Serialize(IFastReportSerializer serializer,String prefix,Object other) {
            if (serializer == null) { throw new ArgumentNullException(nameof(serializer)); }
            serializer.Serialize(this,prefix,other);
            }
        #endregion
        }
    }