using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlSortInTempDbIndexOption))]
    internal sealed class SqlScriptSortInTempDbIndexOption : SqlScriptOnOffIndexOption<SqlSortInTempDbIndexOption>
        {
        #region ctor{IServiceProvider,SqlSortInTempDbIndexOption}
        public SqlScriptSortInTempDbIndexOption(IServiceProvider context,SqlSortInTempDbIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }