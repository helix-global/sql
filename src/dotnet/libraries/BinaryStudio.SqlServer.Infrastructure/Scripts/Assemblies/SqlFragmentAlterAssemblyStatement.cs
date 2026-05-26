using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [SqlScriptObject(typeof(AlterAssemblyStatement))]
    internal class SqlFragmentAlterAssemblyStatement : SqlFragmentObject<AlterAssemblyStatement>
        {
        #region ctor{IServiceProvider,AlterAssemblyStatement}
        public SqlFragmentAlterAssemblyStatement(IServiceProvider context,AlterAssemblyStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }