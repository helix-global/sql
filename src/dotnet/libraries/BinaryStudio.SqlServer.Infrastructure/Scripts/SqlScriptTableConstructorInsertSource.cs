using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptTableConstructorInsertSource : SqlScriptInsertSource<SqlTableConstructorInsertSource>
        {
        #region ctor{IServiceProvider,SqlTableConstructorInsertSource}
        public SqlScriptTableConstructorInsertSource(IServiceProvider context,SqlTableConstructorInsertSource source)
            : base(context,source)
            {
            }
        #endregion
        }
    }