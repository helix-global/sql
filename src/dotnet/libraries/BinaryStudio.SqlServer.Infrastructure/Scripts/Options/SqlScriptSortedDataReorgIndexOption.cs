using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlSortedDataReorgIndexOption))]
    internal sealed class SqlScriptSortedDataReorgIndexOption : SqlScriptIndexOption<SqlSortedDataReorgIndexOption>
        {
        public SqlOnOffValue OnOffValue { get { return Source.OnOffValue; }}

        #region ctor{IServiceProvider,SqlSortedDataReorgIndexOption}
        public SqlScriptSortedDataReorgIndexOption(IServiceProvider context,SqlSortedDataReorgIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }