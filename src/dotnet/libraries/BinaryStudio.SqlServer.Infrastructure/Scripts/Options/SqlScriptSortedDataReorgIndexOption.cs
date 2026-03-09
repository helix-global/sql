using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlSortedDataReorgIndexOption))]
    internal sealed class SqlScriptSortedDataReorgIndexOption : SqlScriptOnOffIndexOption<SqlSortedDataReorgIndexOption>
        {
        #region ctor{IServiceProvider,SqlSortedDataReorgIndexOption}
        public SqlScriptSortedDataReorgIndexOption(IServiceProvider context,SqlSortedDataReorgIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }