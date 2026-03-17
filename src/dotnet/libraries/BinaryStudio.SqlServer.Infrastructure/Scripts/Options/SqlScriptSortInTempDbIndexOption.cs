using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlSortInTempDbIndexOption))]
    internal sealed class SqlScriptSortInTempDbIndexOption : SqlScriptOnOffIndexOption<SqlSortInTempDbIndexOption>
        {
        public override SqlIndexOptionType Type { get { return SqlIndexOptionType.SortInTempDb; }}

        #region ctor{IServiceProvider,SqlSortInTempDbIndexOption}
        public SqlScriptSortInTempDbIndexOption(IServiceProvider context,SqlSortInTempDbIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }