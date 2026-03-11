using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(CreateAssemblyStatement))]
    internal class SqlFragmentCreateAssemblyStatement : SqlFragmentAssemblyStatement<CreateAssemblyStatement>
        {
        #region ctor{IServiceProvider,CreateAssemblyStatement}
        public SqlFragmentCreateAssemblyStatement(IServiceProvider context,CreateAssemblyStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }