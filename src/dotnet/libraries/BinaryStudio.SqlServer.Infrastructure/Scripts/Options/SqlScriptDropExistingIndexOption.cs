using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlDropExistingIndexOption))]
    internal sealed class SqlScriptDropExistingIndexOption : SqlScriptIndexOption<SqlDropExistingIndexOption>
        {
        public override SqlIndexOptionType Type { get { return SqlIndexOptionType.DropExisting; }}

        #region ctor{IServiceProvider,SqlDropExistingIndexOption}
        public SqlScriptDropExistingIndexOption(IServiceProvider context,SqlDropExistingIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }