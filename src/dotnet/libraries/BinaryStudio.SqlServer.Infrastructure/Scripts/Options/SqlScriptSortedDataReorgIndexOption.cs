using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlSortedDataReorgIndexOption))]
    internal sealed class SqlScriptSortedDataReorgIndexOption : SqlScriptOnOffIndexOption<SqlSortedDataReorgIndexOption>
        {
        public override SqlIndexOptionType Type { get { return SqlIndexOptionType.SortedDataReorg; }}

        #region ctor{IServiceProvider,SqlSortedDataReorgIndexOption}
        public SqlScriptSortedDataReorgIndexOption(IServiceProvider context,SqlSortedDataReorgIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }