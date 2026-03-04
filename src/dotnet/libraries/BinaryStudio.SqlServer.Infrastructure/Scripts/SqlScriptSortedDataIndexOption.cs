using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptSortedDataIndexOption : SqlScriptIndexOption<SqlSortedDataIndexOption>
        {
        public SqlOnOffValue OnOffValue { get { return Source.OnOffValue; }}

        #region ctor{IServiceProvider,SqlSortedDataIndexOption}
        public SqlScriptSortedDataIndexOption(IServiceProvider context,SqlSortedDataIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }