using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(OpenRowsetColumnDefinition))]
    internal class SqlFragmentOpenRowsetColumnDefinition : SqlFragmentColumnDefinition<OpenRowsetColumnDefinition>
        {
        #region ctor{IServiceProvider,OpenRowsetColumnDefinition}
        public SqlFragmentOpenRowsetColumnDefinition(IServiceProvider context,OpenRowsetColumnDefinition source)
            : base(context,source)
            {
            }
        #endregion
        }
    }