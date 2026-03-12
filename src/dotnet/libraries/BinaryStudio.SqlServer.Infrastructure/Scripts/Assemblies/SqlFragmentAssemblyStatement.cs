using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlFragmentAssemblyStatement<T> : SqlFragmentObject<T>,ISqlScriptStatement
        where T: AssemblyStatement
        {
        public String StatementPhrase { get; }

        #region ctor{IServiceProvider,T}
        protected SqlFragmentAssemblyStatement(IServiceProvider context,T source)
            : base(context,source)
            {
            StatementPhrase = source.ScriptTokenStream[0].Text.ToUpperInvariant();
            }
        #endregion
        }
    }
