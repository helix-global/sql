using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlSortedDataIndexOption))]
    internal sealed class SqlScriptSortedDataIndexOption : SqlScriptOnOffIndexOption<SqlSortedDataIndexOption>
        {
        #region ctor{IServiceProvider,SqlSortedDataIndexOption}
        public SqlScriptSortedDataIndexOption(IServiceProvider context,SqlSortedDataIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }