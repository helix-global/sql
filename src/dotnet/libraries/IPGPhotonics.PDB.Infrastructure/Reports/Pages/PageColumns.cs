using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Xml;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class PageColumns : FastReportObject
        {
        [UsedImplicitly][Field(Order=1000101)][DefaultValue(1)] public Int32 Count { get; } = 1;
        [UsedImplicitly][Field(Order=1000103,Converter=typeof(SqlSingleCollectionConverter))] public IList<Single> Positions { get; }
        [UsedImplicitly][Field(Order=1000102,ConverterCulture="en-US")][DefaultValue(0f)] public Single Width { get; }

        #region M:Serialize(XmlWriter,String)
        public override void Serialize(XmlWriter writer,String prefix) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            SerializeAttributes(writer,prefix);
            }
        #endregion
        }
    }