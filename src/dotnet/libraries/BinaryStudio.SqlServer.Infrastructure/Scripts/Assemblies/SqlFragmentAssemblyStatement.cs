using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlFragmentAssemblyStatement<T> : SqlFragmentObject<T>,ISqlScriptStatement,ISqlAssembly
        where T: AssemblyStatement
        {
        public virtual String StatementPhrase { get; }
        public SqlObjectIdentifier QualifiedName { get; }
        [UsedImplicitly][Field] public SqlIdentifier Name { get; }

        #region ctor{IServiceProvider,T}
        protected SqlFragmentAssemblyStatement(IServiceProvider context,T source)
            : base(context,source)
            {
            QualifiedName = SqlObjectIdentifier.Create(new []{Name });
            StatementPhrase = (source.ScriptTokenStream.Count >= 3)
                ? $"{source.ScriptTokenStream[0].Text.ToUpperInvariant()} {source.ScriptTokenStream[2].Text.ToUpperInvariant()}"
                : $"{source.ScriptTokenStream[0].Text.ToUpperInvariant()}";
            }
        #endregion

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return Name.ToString();
            }
        #endregion
        }
    }
