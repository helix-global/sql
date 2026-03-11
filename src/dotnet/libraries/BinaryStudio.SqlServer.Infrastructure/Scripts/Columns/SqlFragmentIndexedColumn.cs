using System;
using System.Text;
using JetBrains.Annotations;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(ColumnWithSortOrder))]
    internal class SqlScriptDomIndexedColumn : SqlScriptDomObject<ColumnWithSortOrder>, ISqlScriptIndexedColumn
        {
        [UsedImplicitly][Field] public SqlSortOrder SortOrder { get; }
        public SqlIdentifier Name { get{ return new SqlIdentifier(Source.Column.MultiPartIdentifier[0].Value); }}

        #region ctor{IServiceProvider,ColumnWithSortOrder}
        public SqlScriptDomIndexedColumn(IServiceProvider context,ColumnWithSortOrder source)
            : base(context,source)
            {
            }
        #endregion
        #region M:ToString:String
        public override String ToString()
            {
            var r = new StringBuilder();
            r.Append($"Name: {Name}, SortOrder: {SortOrder}");
            return r.ToString();
            }
        #endregion
        }
    }
